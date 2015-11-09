using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;

namespace Web365
{
    // Note: For instructions on enabling IIS6 or IIS7 classic mode, 
    // visit http://go.microsoft.com/?LinkId=9394801

    public class MvcApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            AreaRegistration.RegisterAllAreas();

            WebApiConfig.Register(GlobalConfiguration.Configuration);
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
            AuthConfig.RegisterAuth();

            Application["online"] = Web365Utility.ConfigWeb.MinOnline;
        }

        protected void Application_Error(object sender, EventArgs e)
        {
            Server.ClearError();

            Response.Redirect("/notfound");
        }

        protected void Session_Start(object sender, EventArgs e)
        {
            Web365Utility.Web365Utility.Statistics();

            Application.Lock();

            Application["online"] = Convert.ToInt32(Application["online"]) + 1;

            Application.UnLock();
        }

        protected void Session_End(object sender, EventArgs e)
        {
            Application.Lock();

            Application["online"] = Convert.ToInt32(Application["online"]) - 1;

            Application.UnLock();
        }

        protected void Application_AcquireRequestState(object sender, EventArgs e)
        {
            var lang = Request.Url.Segments.Length > 1 && (Request.Url.Segments[1] == "en" || Request.Url.Segments[1] == "en/") ? "en" : "vi";

            CultureInfo culture = CultureInfo.GetCultureInfo(lang);

            Thread.CurrentThread.CurrentUICulture = culture;
            Thread.CurrentThread.CurrentCulture = culture;
        }
    }
}