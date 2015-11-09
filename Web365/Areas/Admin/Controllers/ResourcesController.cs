using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Web365Utility;
using Web365Base;
using Web365Business.Back_End.IRepository;
using Web365Domain;
using System;
using System.Xml;

namespace Web365.Areas.Admin.Controllers
{
    public class ResourcesController : BaseController
    {

        // GET: /Admin/ProductType/

        public ResourcesController()
        {

        }

        public ActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public ActionResult GetAllResources(string source)
        {
            var fileName = "~/App_GlobalResources/Resource" + source + (LanguageId == 2 ? ".vi" : string.Empty) + ".resx";

            XmlDocument xmlDocument = new XmlDocument();

            xmlDocument.Load(Server.MapPath(fileName));

            XmlNodeList nodeList = xmlDocument.SelectNodes("/root/data");

            var list = new List<object>();

            foreach (XmlNode item in nodeList)
            {
                list.Add(new {
                    Name = item.Attributes["name"].Value,
                    Value = item["value"].InnerText,
                    Comment = item["comment"] != null ? item["comment"].InnerText : string.Empty
                });
            }

            return Json(new
            {
                list = list
            }, JsonRequestBehavior.AllowGet);

        }

        [HttpPost]
        public ActionResult SaveResources(string source, string name, string value)
        {

            var fileName = "~/App_GlobalResources/Resource" + source + (LanguageId == 2 ? ".vi" : string.Empty) + ".resx";

            XmlDocument xmlDocument = new XmlDocument();
            xmlDocument.Load(Server.MapPath(fileName));

            XmlNode node = xmlDocument.SelectSingleNode("/root/data[@name='" + name + "']");

            node["value"].InnerText = value;

            xmlDocument.Save(Server.MapPath(fileName));
            xmlDocument = null;

            return Json(new
            {
                error = false
            }, JsonRequestBehavior.AllowGet);

        }
    }
}
