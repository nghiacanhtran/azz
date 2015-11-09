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
    public class FileRepositoryFE : BaseFE, IFileRepositoryFE
    {
        public FileModel GetListByType(int id, string ascii, int skip, int top)
        {
            var key = string.Format("FileRepositoryGetListByTypeId{0}{1}{2}", id, skip, top);

            var file = new FileModel();

            if (!this.TryGetCache<FileModel>(out file, key))
            {

                var paramTotal = new SqlParameter
                {
                    ParameterName = "Total",
                    SqlDbType = SqlDbType.Int,
                    Direction = ParameterDirection.Output
                };

                var query = web365db.Database.SqlQuery<FileMapItem>("exec [dbo].[PRC_File_GetFileByType] @TypeID, @TypeAscii, @Skip, @Top, @Total OUTPUT",
                               new SqlParameter("TypeID", id),
                               new SqlParameter("TypeAscii", ascii),
                               new SqlParameter("Skip", skip),
                               new SqlParameter("Top", top),
                               paramTotal);

                file.List = query.Select(f => new FileItem() {
                    ID = f.ID,
                    Name = f.Name,
                    NameAscii = f.NameAscii,
                    FileName = f.FileName
                }).ToList();

                file.Total = Convert.ToInt32(paramTotal.Value);

                this.SetCache(key, file, 10);
            }

            return file;
        }
    }
}
