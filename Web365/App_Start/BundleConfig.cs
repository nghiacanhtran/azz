using System.Web;
using System.Web.Optimization;
using Web365Utility;

namespace Web365
{
    public class BundleConfig
    {
        // For more information on Bundling, visit http://go.microsoft.com/fwlink/?LinkId=254725
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                        "~/Scripts/jquery-{version}.js"));

            bundles.Add(new ScriptBundle("~/bundles/jqueryui").Include(
                        "~/Scripts/jquery-ui-{version}.js"));

            bundles.Add(new ScriptBundle("~/bundles/jqueryval").Include(
                        "~/Scripts/jquery.unobtrusive*",
                        "~/Scripts/jquery.validate*"));

            bundles.Add(new ScriptBundle("~/bundles/scripts").Include(
                        "~/Scripts/js/libs/prefixfree.min.js",
                        "~/Scripts/js/libs/modernizr.min.js",
                        "~/Scripts/js/libs/jquery-1.11.2.min.js",
                        "~/Scripts/js/bootstrap.min.js",
                        "~/Scripts/js/jasny-bootstrap.min.js",
                        "~/Scripts/js/functions.js"));

            // Use the development version of Modernizr to develop with and learn from. Then, when you're
            // ready for production, use the build tool at http://modernizr.com to pick only the tests you need.
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                        "~/Scripts/modernizr-*"));

            bundles.Add(new StyleBundle("~/Content/css").Include(
                "~/Content/css/bootstrap.min.css",
                "~/Content/css/jasny-bootstrap.min.css",
                "~/Content/css/reset.css",
                "~/Content/css/style.css"));

            BundleTable.EnableOptimizations = ConfigWeb.EnableOptimizations;
        }
    }
}