using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using Web365Base;
using Web365Business.Back_End.IRepository;
using Web365Domain;
using Web365Utility;


namespace Web365Business.Back_End.Repository
{
    public class VideoTypeRepository : BaseBE<tblTypeVideo>, IVideoTypeRepository
    {

        /// <summary>
        /// function get all data tblTypeVideo
        /// </summary>
        /// <returns></returns>
        public List<VideoTypeItem> GetList(out int total, string name, int currentRecord, int numberRecord, string propertyNameSort, bool descending, bool isDelete = false)
        {
            var query = from p in web365db.tblTypeVideo
                        where p.Name.ToLower().Contains(name) && p.IsDeleted == isDelete
                        select p;            

            total = query.Count();

            query = descending ? QueryableHelper.OrderByDescending(query, propertyNameSort) : QueryableHelper.OrderBy(query, propertyNameSort);

            return query.Select(p => new VideoTypeItem()
            {
                ID = p.ID,
                Name = p.Name,
                NameAscii = p.NameAscii,
                SEOTitle = p.SEOTitle,
                SEODescription = p.SEODescription,
                SEOKeyword = p.SEOKeyword,
                Number = p.Number,
                Summary = p.Summary,
                Detail = p.Detail,
                Parent = p.Parent,
                IsShow = p.IsShow
            }).Skip(currentRecord).Take(numberRecord).ToList();
        }

        public T GetListForTree<T>(bool isShow = true, bool isDelete = false)
        {
            var query = from p in web365db.tblTypeVideo
                        where p.IsShow == isShow && p.IsDeleted == isDelete
                        select p;

            return (T)(object)query.OrderByDescending(p => p.ID).Select(p => new VideoTypeItem()
            {
                ID = p.ID,
                Name = p.Name,
                NameAscii = p.NameAscii,
                Parent = p.Parent
            }).ToList();
        }

        public T GetItemById<T>(int id)
        {
            var query = from p in web365db.tblTypeVideo
                        where p.ID == id
                        orderby p.ID descending
                        select new VideoTypeItem()
                        {
                            ID = p.ID,
                            Name = p.Name,
                            NameAscii = p.NameAscii,
                            SEOTitle = p.SEOTitle,
                            SEODescription = p.SEODescription,
                            SEOKeyword = p.SEOKeyword,
                            DateCreated = p.DateCreated,
                            DateUpdated = p.DateUpdated,
                            Number = p.Number,
                            PictureID = p.PictureID,
                            Summary = p.Summary,
                            Detail = p.Detail,
                            Parent = p.Parent,
                            IsShow = p.IsShow
                        };
            return (T)(object)query.FirstOrDefault();
        }

        public void Show(int id)
        {
            var typeVideo = web365db.tblTypeVideo.SingleOrDefault(p => p.ID == id);
            typeVideo.IsShow = true;
            web365db.Entry(typeVideo).State = EntityState.Modified;
            web365db.SaveChanges();
        }

        public void Hide(int id)
        {
            var typeVideo = web365db.tblTypeVideo.SingleOrDefault(p => p.ID == id);
            typeVideo.IsShow = false;
            web365db.Entry(typeVideo).State = EntityState.Modified;
            web365db.SaveChanges();
        }

        #region Check
        public bool NameExist(int id, string name)
        {
            var query = web365db.tblTypeVideo.Count(c => c.Name.ToLower() == name.ToLower() && c.ID != id);

            return query > 0;
        }
        #endregion
    }
}
