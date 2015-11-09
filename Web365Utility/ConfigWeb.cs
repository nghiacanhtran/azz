using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;
using System.IO;
using System.Web;
using System.Drawing;
using System.Drawing.Drawing2D;

namespace Web365Utility
{
    public static class ConfigWeb
    {
        public static readonly string TempPath = ConfigurationManager.AppSettings["TempUpload"];

        public static readonly string ImageThumpPath = ConfigurationManager.AppSettings["UploadImageThumb"];

        public static readonly string ImagePath = ConfigurationManager.AppSettings["UploadImage"];

        public static readonly string FilePath = ConfigurationManager.AppSettings["UploadFile"];

        public static readonly bool UseCache = Convert.ToBoolean(ConfigurationManager.AppSettings["UseCache"]);

        public static readonly bool UseOutputCache = Convert.ToBoolean(ConfigurationManager.AppSettings["UseOutputCache"]);

        public static readonly int MinOnline = Convert.ToInt32(ConfigurationManager.AppSettings["MinOnline"]);

        public static readonly int PageSizeNews = Convert.ToInt32(ConfigurationManager.AppSettings["PageSizeNews"]);

        public static readonly string SpecialArticle = ConfigurationManager.AppSettings["SpecialArticle"];

        public static readonly string OtherArticle = ConfigurationManager.AppSettings["OtherArticle"];

        public static readonly bool EnableOptimizations = Convert.ToBoolean(ConfigurationManager.AppSettings["EnableOptimizations"]);
    }
}
