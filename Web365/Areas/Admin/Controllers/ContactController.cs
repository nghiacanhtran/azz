using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Web365Utility;
using Web365Base;
using Web365Business.Back_End.IRepository;
using Web365Domain;
using Newtonsoft.Json.Linq;

namespace Web365.Areas.Admin.Controllers
{
    public class ContactController : BaseController
    {

        private IContactRepository contactRepository;

        // GET: /Admin/ProductType/

        public ContactController(IContactRepository _contactRepository)
        {
            this.contactRepository = _contactRepository;
            this.baseRepository = _contactRepository;
        }

        public ActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public ActionResult GetList(string name, string title, DateTime? fromDate, DateTime? toDate, int currentRecord, int numberRecord, string propertyNameSort, bool descending)
        {
            var total = 0;
            var list = contactRepository.GetList(out total, name, title, fromDate, toDate, currentRecord, numberRecord, propertyNameSort, descending);

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
            var obj = new ContactItem();

            var listProductType = contactRepository.GetListForTree<List<ContactItem>>();

            if (id.HasValue)
                obj = contactRepository.GetItemById<ContactItem>(id.Value);

            return Json(new
            {
                data = obj,
                listType = listProductType
            }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidateInput(false)]
        public ActionResult Action(tblContact objSubmit)
        {

            if (objSubmit.ID == 0)
            {
                objSubmit.DateCreated = DateTime.Now;
                objSubmit.DateUpdated = DateTime.Now;
                objSubmit.IsDeleted = false;
                objSubmit.IsViewed = false;
                contactRepository.Add(objSubmit);
            }
            else
            {             
                var obj = contactRepository.GetById<tblContact>(objSubmit.ID);
                
                UpdateModel(obj);

                objSubmit.DateUpdated = DateTime.Now;

                contactRepository.Update(obj);
            }

            return Json(new
            {
                Error = false
            }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public ActionResult ExportExcel(string name, string title, DateTime? fromDate, DateTime? toDate, int currentRecord, int numberRecord, string propertyNameSort, bool descending)
        {
            try
            {
                var fileName = string.Empty;

                var total = 0;

                var list = contactRepository.GetList(out total, name, title, fromDate, toDate, 0, 10000, propertyNameSort, descending);

                var filePath = Export.ExportToExcel(out fileName, "file_contact", new string[] { "Tên", "Số điện thoại", "Email", "Ngày sinh", "Dự án quan tâm", "Ngày đăng ký" }, new string[] { "Name", "Phone", "Email", "BirthDay", "Title", "DateCreated" }, JArray.FromObject(list));

                var bytes = System.IO.File.ReadAllBytes(filePath);

                return File(bytes, "text/xls", fileName);
            }
            catch (Exception ex)
            {
                Elmah.ErrorSignal.FromCurrentContext().Raise(ex);
            }

            return Content(string.Empty);
        }
    }
}
