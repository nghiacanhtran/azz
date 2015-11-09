using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Web365Domain;

namespace Web365Models
{
    public class LibraryModel
    {
        public VideoModel ListVideo { get; set; }
        public FileModel ListFile { get; set; }
        public PictureModel ListImages { get; set; }
    }
}
