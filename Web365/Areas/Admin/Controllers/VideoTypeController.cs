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
    public class VideoTypeController : BaseController
    {

        private IVideoTypeRepository VideoTypeRepository;

        // GET: /Admin/ProductType/

        public VideoTypeController(IVideoTypeRepository _VideoTypeRepository)
        {
            this.baseRepository = _VideoTypeRepository;
            this.VideoTypeRepository = _VideoTypeRepository;
        }

        public ActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public ActionResult GetList(string name, int currentRecord, int numberRecord, string propertyNameSort, bool descending)
        {
            var total = 0;
            var list = VideoTypeRepository.GetList(out total, name, currentRecord, numberRecord, propertyNameSort, descending);

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
            var obj = new VideoTypeItem();

            var listProductType = VideoTypeRepository.GetListForTree<object>();

            if (id.HasValue)
                obj = VideoTypeRepository.GetItemById<VideoTypeItem>(id.Value);

            return Json(new
            {
                data = obj,
                listType = listProductType
            }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidateInput(false)]
        public ActionResult Action(tblTypeVideo objSubmit)
        {

            if (objSubmit.ID == 0)
            {
                objSubmit.DateCreated = DateTime.Now;
                objSubmit.DateUpdated = DateTime.Now;
                objSubmit.IsDeleted = false;
                objSubmit.IsShow = true;
                VideoTypeRepository.Add(objSubmit);
            }
            else
            {
                var obj = VideoTypeRepository.GetById<tblTypeVideo>(objSubmit.ID);
                
                UpdateModel(obj);

                objSubmit.DateUpdated = DateTime.Now;

                VideoTypeRepository.Update(obj);
            }

            return Json(new
            {
                Error = false
            }, JsonRequestBehavior.AllowGet);
        }
    }
}
