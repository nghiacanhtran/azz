using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Web365Domain;

namespace Web365Models
{
    public class PictureModel
    {
        public List<PictureItem> List { get; set; }
        public int Total { get; set; }        
    }
}
