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
    public class PictureRepositoryFE : BaseFE, IPictureRepositoryFE
    {
        public PictureModel GetListByType(int id, string ascii, int skip, int top)
        {
            var key = string.Format("PictureRepositoryGetListByTypeId{0}{1}{2}", id, skip, top);

            var picture = new PictureModel();

            if (!this.TryGetCache<PictureModel>(out picture, key))
            {

                var paramTotal = new SqlParameter
                {
                    ParameterName = "Total",
                    SqlDbType = SqlDbType.Int,
                    Direction = ParameterDirection.Output
                };

                var query = web365db.Database.SqlQuery<PictureItem>("exec [dbo].[PRC_Picture_GetPictureByType] @TypeID, @TypeAscii, @Skip, @Top, @Total OUTPUT",
                               new SqlParameter("TypeID", id),
                               new SqlParameter("TypeAscii", ascii),
                               new SqlParameter("Skip", skip),
                               new SqlParameter("Top", top),
                               paramTotal);

                picture.List = query.ToList();

                picture.Total = Convert.ToInt32(paramTotal.Value);

                this.SetCache(key, picture, 10);
            }

            return picture;
        }
    }
}
