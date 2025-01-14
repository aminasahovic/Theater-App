using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eTheater.Services
{
    public interface IGlumacPredstavaService:ICRUDService<Model.GlumacPredstava, GlumacPredstavaSearchObject, GlumacPredstavaInsertRequest, GlumacPredstavaUpdateRequest>
    {
    }
}
