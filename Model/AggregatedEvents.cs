using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace etl_service_layer.Model
{
  public class AggregatedEvents
  {
    public AggregatedEvents() { }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public int? Enter { get; set; }
    public int? Leave { get; set; }
    public int? Comment { get; set; }
    public int? HiFive { get; set; }
  }
}
