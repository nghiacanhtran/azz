using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Web365Domain;

namespace Web365Models
{
    public class FooterModel
    {
        public LayoutContentItem Content { get; set; }
        public List<MenuItem> Nav { get; set; }
        public ProductModel ListProduct { get; set; }
    }
}
