using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Web365Utility;
using Web365Base;
using Web365Business.Back_End.IRepository;
using Web365Domain;
using System;
namespace Web365.Areas.Admin.Controllers
{
    public class SupportController : BaseController
    {

        private ISupportRepository supportRepository;
        private ISupportTypeRepository supportTypeRepository;

        // GET: /Admin/ProductType/

        public SupportController(ISupportRepository _supportRepository,
            ISupportTypeRepository _supportTypeRepository)
        {
            this.baseRepository = _supportRepository;
            this.supportRepository = _supportRepository;
            this.supportTypeRepository = _supportTypeRepository;
        }

        public ActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public ActionResult GetList(string name, int currentRecord, int numberRecord, string propertyNameSort, bool descending)
        {
            var total = 0;
            var list = supportRepository.GetList(out total, name, currentRecord, numberRecord, propertyNameSort, descending);

            return Json(new
            {
                total = total,
                list = list
            },
            JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public ActionResult EditForm(int? id)
        {
            var obj = new SupportItem();

            var listType = supportTypeRepository.GetListForTree<object>();

            if (id.HasValue)
                obj = supportRepository.GetItemById<SupportItem>(id.Value);

            return Json(new
            {
                data = obj,
                listType = listType
            }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidateInput(false)]
        public ActionResult Action(tblSupport objSubmit)
        {
            
            if (objSubmit.ID == 0)
            {
                objSubmit.DateCreated = DateTime.Now;
                objSubmit.DateUpdated = DateTime.Now;
                objSubmit.IsDeleted = false;
                objSubmit.IsShow = true;
                supportRepository.Add(objSubmit);
            }
            else
            {
                var obj = supportRepository.GetById<tblSupport>(objSubmit.ID);
                
                UpdateModel(obj);

                objSubmit.DateUpdated = DateTime.Now;

                supportRepository.Update(obj);
            }

            return Json(new
            {
                Error = false
            }, JsonRequestBehavior.AllowGet);
        }
    }
}
