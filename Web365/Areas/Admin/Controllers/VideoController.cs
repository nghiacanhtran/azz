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
    public class VideoController : BaseController
    {

        private IVideoRepository VideoRepository;
        private IVideoTypeRepository VideoTypeRepository;

        // GET: /Admin/ProductType/

        public VideoController(IVideoRepository _VideoRepository,
            IVideoTypeRepository _VideoTypeRepository)
        {
            this.baseRepository = _VideoRepository;
            this.VideoRepository = _VideoRepository;
            this.VideoTypeRepository = _VideoTypeRepository;
        }

        public ActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public ActionResult GetList(string name, string typeId, int currentRecord, int numberRecord, string propertyNameSort, bool descending)
        {
            var listType = string.IsNullOrEmpty(typeId) ? new int[] { } : typeId.Split(',').Select(int.Parse).ToArray();

            var total = 0;

            var list = VideoRepository.GetList(out total, name, listType, currentRecord, numberRecord, propertyNameSort, descending);

            return Json(new
            {
                total = total,
                list = list
            },
            JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public ActionResult GetPropertyFilter()
        {
            var listType = VideoTypeRepository.GetListForTree<object>();

            return Json(new
            {
                listType = listType
            }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public ActionResult GetListByArrayID(int[] arrID)
        {
            var list = VideoRepository.GetListByArrayID(arrID);

            return Json(new
            {
                list = list
            },
            JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public ActionResult EditForm(int? id)
        {
            var obj = new VideoItem();

            var listProductType = VideoTypeRepository.GetListForTree<object>();

            if (id.HasValue)
                obj = VideoRepository.GetItemById<VideoItem>(id.Value);

            return Json(new
            {
                data = obj,
                listType = listProductType
            }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidateInput(false)]
        public ActionResult Action(tblVideo objSubmit)
        {
            if (objSubmit.ID == 0)
            {
                objSubmit.DateCreated = DateTime.Now;
                objSubmit.DateUpdated = DateTime.Now;
                objSubmit.IsDeleted = false;
                objSubmit.IsShow = true;
                VideoRepository.Add(objSubmit);
            }
            else
            {
                var obj = VideoRepository.GetById<tblVideo>(objSubmit.ID);
                
                UpdateModel(obj);

                objSubmit.DateUpdated = DateTime.Now;

                VideoRepository.Update(obj);
            }

            return Json(new
            {
                Error = false
            }, JsonRequestBehavior.AllowGet);
        }
    }
}
