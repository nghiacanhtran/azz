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
    public class FileRepository : BaseBE<tblFile>, IFileRepository
    {

        /// <summary>
        /// function get all data tblFile
        /// </summary>
        /// <returns></returns>
        public List<FileItem> GetList(out int total, string name, int[] typeId, int currentRecord, int numberRecord, string propertyNameSort, bool descending, bool isDelete = false)
        {
            var query = from p in web365db.tblFile
                        where p.Name.ToLower().Contains(name) && p.IsDeleted == isDelete
                        select p;

            query = query.Where(p => p.tblTypeFile.LanguageId == LanguageId);

            if (typeId != null && typeId.Count() > 0)
            {
                query = query.Where(p => typeId.Contains(p.TypeID.Value));
            }

            total = query.Count();

            query = descending ? QueryableHelper.OrderByDescending(query, propertyNameSort) : QueryableHelper.OrderBy(query, propertyNameSort);

            return query.Select(p => new FileItem()
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
                IsShow = p.IsShow
            }).Skip(currentRecord).Take(numberRecord).ToList();
        }

        public List<FileItem> GetListByArrayID(int[] arrId, bool isDelete = false)
        {
            var result = new List<FileItem>();

            var query = from p in web365db.tblFile
                        where arrId.Contains(p.ID) && p.IsDeleted == isDelete
                        orderby p.ID descending
                        select new FileItem()
                        {
                            ID = p.ID,
                            Name = p.Name,
                            FileName = p.FileName,
                            TypeID = p.TypeID,
                            Summary = p.Summary,
                            Size = p.Size,
                            DateCreated = p.DateCreated,
                            DateUpdated = p.DateUpdated,
                            CreatedBy = p.CreatedBy,
                            UpdatedBy = p.UpdatedBy,
                            IsShow = p.IsShow,
                            IsDeleted = p.IsDeleted
                        };

            result = query.ToList();

            result = arrId.Select(item => result.FirstOrDefault(p => p.ID == item)).Where(product => product != null).ToList();

            return result;
        }

        public T GetItemById<T>(int id)
        {
            var query = from p in web365db.tblFile
                        where p.ID == id
                        orderby p.ID descending
                        select new FileItem()
                        {
                            ID = p.ID,
                            Name = p.Name,
                            NameAscii = p.NameAscii,
                            FileName = p.FileName,
                            SEOTitle = p.SEOTitle,
                            SEODescription = p.SEODescription,
                            SEOKeyword = p.SEOKeyword,
                            TypeID = p.TypeID,
                            DateCreated = p.DateCreated,
                            DateUpdated = p.DateUpdated,
                            Number = p.Number,
                            PictureID = p.PictureID,
                            Summary = p.Summary,
                            Detail = p.Detail,
                            IsShow = p.IsShow
                        };
            return (T)(object)query.FirstOrDefault();
        }

        public void Show(int id)
        {
            var file = web365db.tblFile.SingleOrDefault(p => p.ID == id);
            file.IsShow = true;
            web365db.Entry(file).State = EntityState.Modified;
            web365db.SaveChanges();
        }

        public void Hide(int id)
        {
            var file = web365db.tblFile.SingleOrDefault(p => p.ID == id);
            file.IsShow = false;
            web365db.Entry(file).State = EntityState.Modified;
            web365db.SaveChanges();
        }

        #region Check
        public bool NameExist(int id, string name)
        {
            var query = web365db.tblFile.Count(c => c.Name.ToLower() == name.ToLower() && c.tblTypeFile.LanguageId == LanguageId && c.ID != id);

            return query > 0;
        }
        #endregion

        public T GetListForTree<T>(bool isShow = true, bool isDelete = false)
        {
            throw new NotImplementedException();
        }
    }
}
