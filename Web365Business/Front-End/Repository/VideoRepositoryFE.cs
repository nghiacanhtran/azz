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
    public class VideoRepositoryFE : BaseFE, IVideoRepositoryFE
    {
        public VideoModel GetListByType(int id, string ascii, int skip, int top)
        {
            var key = string.Format("VideoRepositoryGetListByTypeId{0}{1}{2}", id, skip, top);

            var Video = new VideoModel();

            if (!this.TryGetCache<VideoModel>(out Video, key))
            {

                var paramTotal = new SqlParameter
                {
                    ParameterName = "Total",
                    SqlDbType = SqlDbType.Int,
                    Direction = ParameterDirection.Output
                };

                var query = web365db.Database.SqlQuery<VideoMapItem>("exec [dbo].[PRC_Video_GetVideoByType] @TypeID, @TypeAscii, @Skip, @Top, @Total OUTPUT",
                               new SqlParameter("TypeID", id),
                               new SqlParameter("TypeAscii", ascii),
                               new SqlParameter("Skip", skip),
                               new SqlParameter("Top", top),
                               paramTotal);

                Video.List = query.Select(f => new VideoItem() {
                    ID = f.ID,
                    Name = f.Name,
                    NameAscii = f.NameAscii,
                    Link = f.Link,
                    Picture = new PictureItem()
                    {
                        FileName = f.URLPicture
                    }
                }).ToList();

                Video.Total = Convert.ToInt32(paramTotal.Value);

                this.SetCache(key, Video, 10);
            }

            return Video;
        }
    }
}
