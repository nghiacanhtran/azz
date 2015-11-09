using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Web365Domain;

namespace Web365Models
{
    public class FileModel
    {
        public List<FileItem> List { get; set; }
        public int Total { get; set; }        
    }
}
