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
    public class ArticleRepository : BaseBE<tblArticle>, IArticleRepository
    {
        /// <summary>
        /// function get all data tblArticle
        /// </summary>
        /// <returns></returns>
        public List<ArticleItem> GetList(out int total, string name, int? typeId, int? groupId, int currentRecord, int numberRecord, string propertyNameSort, bool descending, bool isDelete = false)
        {
            var query = from p in web365db.tblArticle
                        where p.Title.ToLower().Contains(name) && p.IsDeleted == isDelete
                        select p;

            query = query.Where(p => p.tblTypeArticle.LanguageId == LanguageId);

            if(typeId.HasValue){
                query = query.Where(a => a.TypeID == typeId);
            }

            if (groupId.HasValue)
            {
                query = query.Where(a => a.tblGroup_Article_Map.Any(g => g.GroupID == groupId));
            }

            total = query.Count();

            query = descending ? QueryableHelper.OrderByDescending(query, propertyNameSort) : QueryableHelper.OrderBy(query, propertyNameSort);

            return query.Select(p => new ArticleItem()
            {
                ID = p.ID,
                Title = p.Title,
                TitleAscii = p.TitleAscii,
                SEOTitle = p.SEOTitle,
                SEODescription = p.SEODescription,
                SEOKeyword = p.SEOKeyword,
                Number = p.Number,
                Summary = p.Summary,
                Detail = p.Detail,
                IsShow = p.IsShow
            }).Skip(currentRecord).Take(numberRecord).ToList();
        }

        public T GetItemById<T>(int id)
        {
            var result = GetById<tblArticle>(id);

            return (T)(object)new ArticleItem()
            {
                ID = result.ID,       
                TypeID = result.TypeID,
                Title = result.Title,
                TitleAscii = result.TitleAscii,
                SEOTitle = result.SEOTitle,
                SEODescription = result.SEODescription,
                SEOKeyword = result.SEOKeyword,
                DateCreated = result.DateCreated,
                DateUpdated = result.DateUpdated,
                Number = result.Number,
                PictureID = result.PictureID,
                Summary = result.Summary,
                Detail = result.Detail,
                IsShow = result.IsShow,
                Viewed = result.Viewed,
                ListGroupID = result.tblGroup_Article_Map.Select(g => g.GroupID.Value).ToArray(),
                ListPictureID = result.tblPicture1.Select(p => p.ID).ToArray()
            };
        }

        public void Show(int id)
        {
            var article = web365db.tblArticle.SingleOrDefault(p => p.ID == id);
            article.IsShow = true;
            web365db.Entry(article).State = EntityState.Modified;
            web365db.SaveChanges();
        }

        public void Hide(int id)
        {
            var article = web365db.tblArticle.SingleOrDefault(p => p.ID == id);
            article.IsShow = false;
            web365db.Entry(article).State = EntityState.Modified;
            web365db.SaveChanges();
        }

        public void ResetListPicture(int id, string listPictureId)
        {
            web365db.Database.SqlQuery<object>("EXEC [dbo].[PRC_ResetPictureArticle] {0}, {1}", id, listPictureId).FirstOrDefault();
        }

        #region Check
        public bool NameExist(int id, string name)
        {
            var query = web365db.tblArticle.Count(c => c.Title.ToLower() == name.ToLower() && c.tblTypeArticle.LanguageId == LanguageId && c.ID != id);

            return query > 0;
        }
        #endregion

        public T GetListForTree<T>(bool isShow = true, bool isDelete = false)
        {
            throw new NotImplementedException();
        }
    }
}
