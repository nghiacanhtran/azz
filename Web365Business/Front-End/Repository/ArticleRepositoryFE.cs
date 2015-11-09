using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using Web365Base;
using Web365Business.Front_End.IRepository;
using Web365Domain;
using Web365Models;
using Web365Utility;

namespace Web365Business.Front_End.Repository
{
    public class ArticleRepositoryFE : BaseFE, IArticleRepositoryFE
    {
        public ArticleItem GetItemById(int id)
        {
            var key = string.Format("ArticleRepositoryGetItemById{0}", id);

            var article = new ArticleItem();

            if (!this.TryGetCache<ArticleItem>(out article, key))
            {
                var result = (from p in web365db.tblArticle
                              where p.ID == id
                              orderby p.ID descending
                              select p).FirstOrDefault();

                article = new ArticleItem()
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
                    IsShow = result.IsShow
                };

                this.SetCache(key, article, 10);
            }

            return article;
        }

        public ArticleItem GetItemByNameAscii(string nameAscii, bool isShow = true, bool isDeleted = false)
        {
            var key = string.Format("ArticleRepositoryGetItemByNameAscii{0}{1}", nameAscii, LanguageId);

            var article = new ArticleItem();

            if (!this.TryGetCache<ArticleItem>(out article, key))
            {
                var result = (from p in web365db.tblArticle
                              where p.TitleAscii == nameAscii && p.tblTypeArticle.LanguageId == LanguageId && p.IsShow == isShow && p.IsDeleted == isDeleted
                              orderby p.ID descending
                              select p).FirstOrDefault();

                article = new ArticleItem()
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
                              ArticleType = new ArticleTypeItem()
                              {
                                  ID = result.tblTypeArticle.ID,
                                  Name = result.tblTypeArticle.Name,
                                  NameAscii = result.tblTypeArticle.NameAscii
                              },
                              ListPicture = result.tblPicture1.Select(p => new PictureItem()
                              {
                                  FileName = p.FileName
                              }).ToList()
                          };

                this.SetCache(key, article, 10);
            }

            return article;
        }

        public ListArticleModel GetListByType(int typeID, string nameAscii, int currentRecord, int pageSize, bool isShow = true, bool isDeleted = false)
        {
            var key = string.Format("ArticleRepositoryGetListByType{0}{1}{2}{3}", typeID, nameAscii, currentRecord, isShow);

            var result = new ListArticleModel();

            if (!this.TryGetCache<ListArticleModel>(out result, key))
            {

                var paramTotal = new SqlParameter
                {
                    ParameterName = "Total",
                    SqlDbType = SqlDbType.Int,
                    Direction = ParameterDirection.Output
                };

                var query = web365db.Database.SqlQuery<ArticleMapItem>("exec [dbo].[PRC_GetListNewsByType] @TypeID, @TypeAscii, @Language, @CurrentRecord, @PageSize, @Total OUTPUT",
                    new SqlParameter("TypeID", typeID),
                    new SqlParameter("TypeAscii", nameAscii),
                    new SqlParameter("Language", LanguageId),
                    new SqlParameter("CurrentRecord", currentRecord),
                    new SqlParameter("PageSize", pageSize),
                    paramTotal);

                result.List = query.Select(p => new ArticleItem()
                {
                    ID = p.ID,
                    Title = p.Title,
                    TitleAscii = p.TitleAscii,
                    Summary = p.Summary,
                    Picture = new PictureItem()
                    {
                        FileName = p.PictureURL
                    },
                    ArticleType = new ArticleTypeItem()
                    {
                        Name = p.TypeName,
                        NameAscii = p.TypeNameAscii,
                        ParentName = p.TypeParentName,
                        ParentAscii = p.TypeParentNameAscii
                    }
                }).ToList();

                result.total = Convert.ToInt32(paramTotal.Value);

                this.SetCache(key, result, 10);
            }

            return result;
        }

        public ListArticleModel GetListByArrType(int[] arrType, int currentRecord, int pageSize, bool isShow = true, bool isDeleted = false)
        {
            var key = string.Format("ArticleRepositoryGetListByArrType{0}{1}", arrType, isShow);

            var result = new ListArticleModel();

            if (!this.TryGetCache<ListArticleModel>(out result, key))
            {

                var query = from p in web365db.tblArticle
                            where arrType.Contains(p.TypeID.Value) && p.IsShow == isShow && p.IsDeleted == isDeleted
                            orderby p.Number descending, p.ID descending
                            select new ArticleItem()
                            {
                                ID = p.ID,
                                TypeID = p.TypeID,
                                Title = p.Title,
                                TitleAscii = p.TitleAscii,
                                SEOTitle = p.SEOTitle,
                                Summary = p.Summary,
                                Picture = new PictureItem()
                                {
                                    ID = p.tblPicture.ID,
                                    Name = p.tblPicture.Name,
                                    FileName = p.tblPicture.FileName
                                },
                                ArticleType = new ArticleTypeItem()
                                {
                                    ID = p.tblTypeArticle.ID,
                                    Name = p.tblTypeArticle.Name,
                                    NameAscii = p.tblTypeArticle.NameAscii,
                                    SEOTitle = p.tblTypeArticle.SEOTitle,
                                    SEODescription = p.tblTypeArticle.SEODescription,
                                    SEOKeyword = p.tblTypeArticle.SEOKeyword
                                }
                            };

                result.total = query.Count();

                result.List = query.Skip(currentRecord).Take(pageSize).ToList();

                this.SetCache(key, result, 10);
            }

            return result;
        }

        public List<ArticleItem> GetTopByType(int type, int skip, int top, bool isShow = true, bool isDeleted = false)
        {
            var key = string.Format("ArticleRepositoryGetTopByType{0}{1}", type, isShow);

            var list = new List<ArticleItem>();

            if (!this.TryGetCache<List<ArticleItem>>(out list, key))
            {

                list = (from p in web365db.tblArticle
                        where p.TypeID == type && p.IsShow == isShow && p.IsDeleted == isDeleted
                        orderby p.ID descending
                        select new ArticleItem()
                         {
                             ID = p.ID,
                             TypeID = p.TypeID,
                             Title = p.Title,
                             TitleAscii = p.TitleAscii,
                             SEOTitle = p.SEOTitle,
                             Picture = new PictureItem()
                             {
                                 ID = p.tblPicture.ID,
                                 Name = p.tblPicture.Name,
                                 FileName = p.tblPicture.FileName
                             },
                             ArticleType = new ArticleTypeItem()
                             {
                                 ID = p.tblTypeArticle.ID,
                                 Name = p.tblTypeArticle.Name,
                                 NameAscii = p.tblTypeArticle.NameAscii,
                                 SEOTitle = p.tblTypeArticle.SEOTitle,
                                 SEODescription = p.tblTypeArticle.SEODescription,
                                 SEOKeyword = p.tblTypeArticle.SEOKeyword
                             }
                         }).Skip(skip).Take(top).ToList();

                this.SetCache(key, list, 10);
            }

            return list;
        }

        public List<ArticleItem> GetOtherArticle(int type, int articleId, int skip, int top, bool isShow = true, bool isDeleted = false)
        {
            var key = string.Format("ArticleRepositoryGetOtherArticle{0}{1}", type, isShow);

            var list = new List<ArticleItem>();

            if (!this.TryGetCache<List<ArticleItem>>(out list, key))
            {

                list = (from p in web365db.tblArticle
                        where p.TypeID == type && p.ID < articleId && p.IsShow == isShow && p.IsDeleted == isDeleted
                        orderby p.ID descending
                        select new ArticleItem()
                        {
                            ID = p.ID,
                            TypeID = p.TypeID,
                            Title = p.Title,
                            TitleAscii = p.TitleAscii,
                            SEOTitle = p.SEOTitle,
                            Picture = new PictureItem()
                            {
                                ID = p.tblPicture.ID,
                                Name = p.tblPicture.Name,
                                FileName = p.tblPicture.FileName
                            },
                            ArticleType = new ArticleTypeItem()
                            {
                                ID = p.tblTypeArticle.ID,
                                Name = p.tblTypeArticle.Name,
                                NameAscii = p.tblTypeArticle.NameAscii,
                                ParentName = p.tblTypeArticle.tblTypeArticle2.Name,
                                ParentAscii = p.tblTypeArticle.tblTypeArticle2.NameAscii,
                                SEOTitle = p.tblTypeArticle.SEOTitle,
                                SEODescription = p.tblTypeArticle.SEODescription,
                                SEOKeyword = p.tblTypeArticle.SEOKeyword
                            }
                        }).Skip(skip).Take(top).ToList();

                this.SetCache(key, list, 10);
            }

            return list;
        }

        public ListArticleModel ArticleSeach(string[] keyword, string[] keywordAscii, int currentRecord, int top, bool isShow = true, bool isDeleted = false)
        {
            var key = string.Format("ArticleRepositoryArticleSeach{0}{1}{2}{3}", keyword, keywordAscii, currentRecord, top);

            var list = new ListArticleModel();

            if (!this.TryGetCache<ListArticleModel>(out list, key))
            {

                var query = (from p in web365db.tblArticle
                             where (keyword.All(k => p.Title.ToLower().Contains(k)) || keyword.All(k => p.TitleAscii.Contains(k))) && p.TypeID > 1 && p.tblTypeArticle.LanguageId == LanguageId && p.IsShow == isShow && p.IsDeleted == isDeleted
                             orderby p.ID descending
                             select new ArticleItem()
                             {
                                 ID = p.ID,
                                 Title = p.Title,
                                 TitleAscii = p.TitleAscii,
                                 SEOTitle = p.SEOTitle,
                                 Summary = p.Summary,
                                 Picture = new PictureItem()
                                 {
                                     Name = p.tblPicture != null ? p.tblPicture.Name : string.Empty,
                                     FileName = p.tblPicture != null ? p.tblPicture.FileName : string.Empty
                                 },
                                 ArticleType = new ArticleTypeItem()
                                 {
                                     ID = p.tblTypeArticle != null ? p.tblTypeArticle.ID : 0,
                                     Name = p.tblTypeArticle.Name,
                                     NameAscii = p.tblTypeArticle.NameAscii,
                                     ParentAscii = p.tblTypeArticle.tblTypeArticle2.NameAscii
                                 }
                             });

                list.total = query.Count();

                list.List = query.Skip(currentRecord).Take(top).ToList();

                this.SetCache(key, list, 10);
            }

            return list;
        }

        public ListArticleModel GetListByGroup(int groupId, int skip, int top, bool isShow = true, bool isDeleted = false)
        {
            var key = string.Format("ArticleRepositoryGetListByStatus{0}{1}{2}{3}", groupId, skip, top, LanguageId);

            var list = new ListArticleModel();

            if (!this.TryGetCache<ListArticleModel>(out list, key))
            {

                var query = (from p in web365db.tblGroup_Article_Map
                             where p.GroupID == groupId && p.tblArticle.tblTypeArticle.LanguageId == LanguageId && p.tblArticle.IsShow == isShow && p.tblArticle.IsDeleted == isDeleted
                             orderby p.ID descending
                             select new ArticleItem()
                             {
                                 ID = p.tblArticle.ID,
                                 TypeID = p.tblArticle.TypeID,
                                 Title = p.tblArticle.Title,
                                 TitleAscii = p.tblArticle.TitleAscii,
                                 SEOTitle = p.tblArticle.SEOTitle,
                                 Summary = p.tblArticle.Summary,
                                 Picture = new PictureItem()
                                 {
                                     ID = p.tblArticle.tblPicture.ID,
                                     Name = p.tblArticle.tblPicture.Name,
                                     FileName = p.tblArticle.tblPicture.FileName
                                 },
                                 ArticleType = new ArticleTypeItem()
                                 {
                                     ID = p.tblArticle.tblTypeArticle.ID,
                                     Name = p.tblArticle.tblTypeArticle.Name,
                                     NameAscii = p.tblArticle.tblTypeArticle.NameAscii,
                                     ParentName = p.tblArticle.tblTypeArticle.tblTypeArticle2.Name,
                                     ParentAscii = p.tblArticle.tblTypeArticle.tblTypeArticle2.NameAscii,
                                 }
                             });

                list.total = query.Count();

                list.List = query.Skip(skip).Take(top).ToList();

                this.SetCache(key, list, 10);
            }

            return list;
        }

        public ListArticleModel GetListByTypeAndDetail(int typeId, int skip, int top, bool isShow = true, bool isDeleted = false)
        {
            var key = string.Format("ArticleRepositoryGetListByTypeAndDetail{0}{1}{2}", typeId, skip, top);

            var list = new ListArticleModel();

            if (!this.TryGetCache<ListArticleModel>(out list, key))
            {

                var query = (from p in web365db.tblArticle
                             where p.TypeID == typeId && p.IsShow == isShow && p.IsDeleted == isDeleted
                             orderby p.Number descending, p.ID ascending
                             select new ArticleItem()
                             {
                                 ID = p.ID,
                                 TypeID = p.TypeID,
                                 Title = p.Title,
                                 TitleAscii = p.TitleAscii,
                                 SEOTitle = p.SEOTitle,
                                 Summary = p.Summary,
                                 Detail = p.Detail,
                                 Picture = new PictureItem()
                                 {
                                     ID = p.tblPicture != null ? p.tblPicture.ID : 0,
                                     Name = p.tblPicture.Name,
                                     FileName = p.tblPicture.FileName
                                 },
                                 ArticleType = new ArticleTypeItem()
                                 {
                                     ID = p.tblTypeArticle.ID,
                                     Name = p.tblTypeArticle.Name,
                                     NameAscii = p.tblTypeArticle.NameAscii,
                                     ParentAscii = p.tblTypeArticle.tblTypeArticle2.NameAscii,
                                     ParentName = p.tblTypeArticle.tblTypeArticle2.Name
                                 }
                             });

                list.total = query.Count();

                list.List = query.Skip(skip).Take(top).ToList();

                this.SetCache(key, list, 10);
            }

            return list;
        }
    }
}
