using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Web365Base;
using Web365Business.Front_End.IRepository;
using Web365Models;

namespace Web365.Controllers
{
    public class HomeController : BaseController
    {
        private readonly IOtherRepositoryFE otherRepositoryFE;

        public HomeController(IOtherRepositoryFE _otherRepositoryFE)
        {
            otherRepositoryFE = _otherRepositoryFE;
        }

        [Cache("Home")]
        public ActionResult Index()
        {
            return View();
        }

        [Cache("Home")]
        public ActionResult Notfound()
        {
            return View();
        }

        [HttpPost]
        public ActionResult AddContact(bool? gender, string name, string email, string phone, string birth, string project)
        {
            try
            {
                var contact = new tblContact()
                {
                    Title = project,
                    Address = string.Empty,
                    DateCreated = DateTime.Now,
                    DateUpdated = DateTime.Now,
                    Email = email,
                    IsDeleted = false,
                    IsViewed = false,
                    Name = name,
                    Phone = phone
                };

                var result = otherRepositoryFE.AddContact(contact);

                return Json(new
                {
                    error = !result

                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                Elmah.ErrorLog.GetDefault(System.Web.HttpContext.Current).Log(new Elmah.Error(ex));
            }

            return Json(new
            {
                error = true

            }, JsonRequestBehavior.AllowGet);
            
        }
    }
}
