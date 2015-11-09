using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Web365.Filters;
using WebMatrix.WebData;

namespace Web365.Areas.Admin.Controllers
{
    [InitializeSimpleMembership]
    public class LoginController : Controller
    {
        //
        // GET: /Admin/Login/

        public ActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Login(string userName, string password, bool psesistCookie)
        {

            var result = WebSecurity.Login(userName, password, psesistCookie);

            return Json(new
            {
                result = result,
                message = string.Empty
            },
            JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult Logout()
        {

            WebSecurity.Logout();

            return Json(new
            {
                result = true,
                message = string.Empty
            },
            JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult ChangePassword(string currentPass, string newPass)
        {

            var result = WebSecurity.ChangePassword(WebSecurity.CurrentUserName, currentPass, newPass);

            return Json(new
            {
                result = result,
                message = string.Empty
            },
            JsonRequestBehavior.AllowGet);
        }

    }
}
