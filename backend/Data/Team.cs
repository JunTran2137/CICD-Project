using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Backend.Data;

public partial class Team
{
    [Key]
    public int TeamId { get; set; }

    public string TeamName { get; set; } = null!;

    public int? CaptainId { get; set; }
}
