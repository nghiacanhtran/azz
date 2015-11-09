using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace Web365
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            routes.MapRoute(
                "Ajax",
                "ajax/{controller}/{action}",
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "English",
                "en",
                new { controller = "Home", action = "Index", id = UrlParameter.Optional },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "Notfound",
                "notfound",
                new { controller = "Home", action = "Notfound" },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "NotfoundEN",
                "en/notfound",
                new { controller = "Home", action = "Notfound" },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "Contact",
                "dang-ky",
                new { controller = "Home", action = "Contact" },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "ContactEN",
                "en/register",
                new { controller = "Home", action = "Contact" },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "About",
                "gioi-thieu",
                new { controller = "Home", action = "About" },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "AboutDetail",
                "gioi-thieu/{ascii}",
                new { controller = "Home", action = "About" },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "AboutEN",
                "en/about",
                new { controller = "Home", action = "About" },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "AboutDetailEN",
                "en/about/{ascii}",
                new { controller = "Home", action = "About" },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "Library",
                "thu-vien",
                new { controller = "Home", action = "Library" },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "LibraryEN",
                "en/library",
                new { controller = "Home", action = "Library" },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "Article",
                "tin-tuc",
                new { controller = "Article", action = "List" },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "ArticleEN",
                "news",
                new { controller = "Article", action = "List" },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "ArticleList",
                "tin-tuc/{type}",
                new { controller = "Article", action = "List" },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "ArticleListEN",
                "en/news/{type}",
                new { controller = "Article", action = "List" },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "DetailArticle",
                "tin-tuc/{type}/{ascii}",
                new { controller = "Article", action = "Detail" },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "DetailArticleEN",
                "en/news/{type}/{ascii}",
                new { controller = "Article", action = "Detail" },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "Search",
                "tim-kiem",
                new { controller = "Search", action = "Index" },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "SearchEN",
                "en/search",
                new { controller = "Search", action = "Index" },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "Product",
                "vincom-shop-house",
                new { controller = "Project", action = "Index" },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "ProductEN",
                "en/vincom-shop-house",
                new { controller = "Project", action = "Index" },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "ProductDetail",
                "{project}",
                new { controller = "Product", action = "Detail" },
                new[] { "Web365.Controllers" }
            );

            routes.MapRoute(
                "ProductDetailEN",
                "en/{project}",
                new { controller = "Product", action = "Detail" },
                new[] { "Web365.Controllers" }
            );            

            routes.MapRoute(
                "Default",
                "{controller}/{action}/{id}",
                new { controller = "Home", action = "Index", id = UrlParameter.Optional },
                new[] { "Web365.Controllers" }
            );
        }
    }
}