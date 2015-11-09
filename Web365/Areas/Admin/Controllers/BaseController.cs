using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Web365.Filters;
using Web365Business.Back_End.IRepository;

namespace Web365.Areas.Admin.Controllers
{
    [AuthorizeFilter]
    [InitializeSimpleMembership]
    public class BaseController : Controller
    {
        //
        // GET: /Admin/Base/
        public IBaseRepository baseRepository;

        [HttpGet]
        public ActionResult GetListForTree()
        {
            var list = baseRepository.GetListForTree<object>();

            return Json(new
            {
                list = list
            },
            JsonRequestBehavior.AllowGet);
        } 

        [HttpGet]
        public ActionResult Detail(int id)
        {
            var obj = baseRepository.GetItemById<object>(id);

            return Json(new
            {
                data = obj
            }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult ShowAll(int[] listId)
        {
            foreach (var item in listId)
            {
                baseRepository.Show(item);
            }

            return Json(new
            {
                Error = false
            }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult HideAll(int[] listId)
        {
            foreach (var item in listId)
            {
                baseRepository.Hide(item);
            }

            return Json(new
            {
                Error = false
            }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult Delete(int[] listId)
        {
            foreach (var item in listId)
            {
                baseRepository.Delete(item);
            }

            return Json(new
            {
                Error = false
            }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult NameExist(int id, string name)
        {
            var result = baseRepository.NameExist(id, name);

            return Json(new
            {
                exist = !result
            }, JsonRequestBehavior.AllowGet);
        }

        public int LanguageId
        {
            get
            {
                return Request.Cookies[".ASPL"] != null ? Convert.ToInt32(Request.Cookies[".ASPL"].Value) : 1;
            }
        }
    }
}
