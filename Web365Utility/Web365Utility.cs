using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net.Mail;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Xml;
using System.Xml.Linq;

namespace Web365Utility
{
    public static class Web365Utility
    {
        public static void Statistics()
        {
            int num;

            try
            {
                XmlDocument xmlDocument = new XmlDocument();
                xmlDocument.Load(HttpContext.Current.Server.MapPath("~/statistics.xml"));

                XmlNode str = xmlDocument.SelectSingleNode("/Statistics/Day");
                if (DateTime.Now.Day == Convert.ToInt32(str.ChildNodes[0].InnerText))
                {
                    num = Int32.Parse(str.ChildNodes[1].InnerText) + 1;
                    str.ChildNodes[1].InnerText = num.ToString();
                }
                else
                {
                    XmlNode yesterday = xmlDocument.SelectSingleNode("/Statistics/Yesterday");
                    yesterday.ChildNodes[0].InnerText = str.ChildNodes[1].InnerText;
                    str.ChildNodes[1].InnerText = "1";
                }
                str.ChildNodes[0].InnerText = DateTime.Now.Day.ToString();

                XmlNode week = xmlDocument.SelectSingleNode("/Statistics/Week");
                if (DateTime.Now.DayOfWeek.ToString() == "Monday" && week.ChildNodes[0].InnerText == "false")
                {

                    XmlNode preWeek = xmlDocument.SelectSingleNode("/Statistics/PreWeek");
                    preWeek.ChildNodes[0].InnerText = week.ChildNodes[1].InnerText;
                    week.ChildNodes[0].InnerText = "true";
                    week.ChildNodes[1].InnerText = "1";
                }
                else
                {
                    num = Int32.Parse(week.ChildNodes[1].InnerText) + 1;
                    week.ChildNodes[0].InnerText = "false";
                    week.ChildNodes[1].InnerText = num.ToString();
                }

                XmlNode month = xmlDocument.SelectSingleNode("/Statistics/Month");
                if (DateTime.Now.Day > 1)
                {
                    num = Int32.Parse(month.ChildNodes[0].InnerText) + 1;
                    month.ChildNodes[0].InnerText = num.ToString();
                }
                else
                {
                    month.ChildNodes[0].InnerText = "1";
                }

                XmlNode xmlNodes = xmlDocument.SelectSingleNode("/Statistics/Total");
                num = Int32.Parse(xmlNodes.ChildNodes[0].InnerText) + 1;
                xmlNodes.ChildNodes[0].InnerText = num.ToString();

                xmlDocument.Save(HttpContext.Current.Server.MapPath("~/statistics.xml"));
                xmlDocument = null;
            }
            catch (Exception ex)
            {

            }
        }

        public static string GetInfoStatistics()
        {
            try
            {
                var xDocument = XDocument.Load(HttpContext.Current.Server.MapPath("~/Statistics.xml"));

                var collection =
                    from item in xDocument.Descendants("Statistics")
                    select item.Element("Yesterday").Element("Total").Value
                        + "," + item.Element("Day").Element("Total").Value
                        + "," + item.Element("Week").Element("Total").Value
                        + "," + item.Element("PreWeek").Element("Total").Value
                        + "," + item.Element("Month").Element("Total").Value
                        + "," + item.Element("Total").Element("Number").Value;

                return collection.FirstOrDefault();
            }
            catch (Exception ex)
            {
                return string.Empty;
            }

        }

        public static string GetPathThumbPicture(string fileName)
        {
            try
            {
                return ConfigWeb.ImageThumpPath + fileName;
            }
            catch (Exception)
            {
                return string.Empty;
            }
        }

        public static string GetPathPicture(string fileName)
        {
            try
            {
                return ConfigWeb.ImagePath + fileName;
            }
            catch (Exception)
            {
                return string.Empty;
            }
        }

        public static string GetPathFile(string fileName)
        {
            try
            {
                return ConfigWeb.FilePath + fileName;
            }
            catch (Exception)
            {
                return string.Empty;
            }
        }

        public static string ConvertToAscii(string str)
        {
            str = str.ToLower().Trim();
            str = Regex.Replace(str, "[á|à|ả|ã|ạ|â|ă|ấ|ầ|ẩ|ẫ|ậ|ắ|ằ|ẳ|ẵ|ặ]", "a", RegexOptions.IgnoreCase);
            str = Regex.Replace(str, "[é|è|ẻ|ẽ|ẹ|ê|ế|ề|ể|ễ|ệ]", "e", RegexOptions.IgnoreCase);
            str = Regex.Replace(str, "[ú|ù|ủ|ũ|ụ|ư|ứ|ừ|ử|ữ|ự]", "u", RegexOptions.IgnoreCase);
            str = Regex.Replace(str, "[í|ì|ỉ|ĩ|ị]", "i", RegexOptions.IgnoreCase);
            str = Regex.Replace(str, "[ó|ò|ỏ|õ|ọ|ô|ơ|ố|ồ|ổ|ỗ|ộ|ớ|ờ|ở|ỡ|ợ]", "o", RegexOptions.IgnoreCase);
            str = Regex.Replace(str, "[đ|Đ]", "d", RegexOptions.IgnoreCase);
            str = Regex.Replace(str, "[ý|ỳ|ỷ|ỹ|ỵ|Ý|Ỳ|Ỷ|Ỹ|Ỵ]", "y", RegexOptions.IgnoreCase);
            str = Regex.Replace(str, "[,|~|@|/|.|:|?|#|$|%|&|*|(|)|+|”|“|'|\"|!|`|–]", "", RegexOptions.IgnoreCase);
            str = Regex.Replace(str, @"\s+", " ");
            str = Regex.Replace(str, "[\\s]", "-");
            str = Regex.Replace(str, @"-+", "-");

            return str;
        }

        public static int[] StringToArrayInt(string str)
        {
            try
            {
                return str.Split(',').Select(x => int.Parse(x)).ToArray();
            }
            catch (Exception)
            {
                return new int[0];
            }
        }

        public static string ConvertNumber(string number)
        {
            var result = "0";
            try
            {
                if (!string.IsNullOrEmpty(number))
                {
                    result = ConvertNumber(Int32.Parse(number));
                }
            }
            catch (Exception)
            {
            }

            return result;
        }

        public static string ConvertNumber(int? number)
        {
            var result = "0";
            try
            {
                if (number.HasValue && number != 0)
                {
                    result = number.Value.ToString("#,#");
                    if (result.Contains(","))
                        result = result.Replace(',', '.');
                }
            }
            catch (Exception)
            {
            }

            return result;
        }

        public static string ConvertNumber(decimal? number)
        {
            var result = "0";
            try
            {
                if (number.HasValue && number != 0)
                {
                    result = number.Value.ToString("#,#");
                    if (result.Contains(","))
                        result = result.Replace(',', '.');
                }
            }
            catch (Exception)
            {
            }

            return result;
        }

        public static string StringBase64ToString(string str)
        {
            var encodedDataAsBytes = Convert.FromBase64String(str);

            return Encoding.UTF8.GetString(encodedDataAsBytes);
        }

        public static string StringToBase64(string str)
        {
            var bytes = Encoding.UTF8.GetBytes(str);

            return Convert.ToBase64String(bytes);

        }

        public static string MD5Hash(string input)
        {
            using (var md5Hash = MD5.Create())
            {
                var data = md5Hash.ComputeHash(Encoding.UTF8.GetBytes(input));

                var sBuilder = new StringBuilder();

                for (var i = 0; i < data.Length; i++)
                {
                    sBuilder.Append(data[i].ToString("x2"));
                }

                return sBuilder.ToString();
            }
        }

        public static void SendMail(string email, string title, string content)
        {

            SmtpClient smtp = new SmtpClient
            {
                Host = "smtp.gmail.com", // smtp server address here…
                Port = 25,
                EnableSsl = true,
                DeliveryMethod = SmtpDeliveryMethod.Network,
                Credentials = new System.Net.NetworkCredential("qaz09wsx@gmail.com", "0312696652"),
                Timeout = 30000,
            };

            MailMessage message = new MailMessage("qaz09wsx@gmail.com", email, title, content);

            message.IsBodyHtml = true;

            smtp.Send(message);

            //using (MailMessage mail = new MailMessage())
            //{
            //    mail.To.Add(email);
            //    mail.Subject = title;
            //    mail.Body = title;
            //    mail.IsBodyHtml = true;

            //    using (SmtpClient smtp = new SmtpClient())
            //    {
            //        smtp.Send(mail);
            //    }
            //}
        }

        public static string GetRouterValue(string router)
        {
            try
            {
                return System.Web.HttpContext.Current.Request.RequestContext.RouteData.Values[router].ToString();
            }
            catch (Exception)
            {
                return string.Empty;
            }
        }
    }
}
