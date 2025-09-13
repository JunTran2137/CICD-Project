using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Backend.Data;

namespace Backend.Controllers {
    [Route("api/[controller]")]
    [ApiController]
    public class BowlingLeagueController : ControllerBase {
        private IBowlingLeagueRepository _bowlingLeagueRepository;
        public BowlingLeagueController(IBowlingLeagueRepository temp) { _bowlingLeagueRepository = temp; }

        [HttpGet]
        public IEnumerable<Bowler> Get() {
            var bowlingLeagueData = _bowlingLeagueRepository.Bowlers.ToArray();

            return bowlingLeagueData;
        }
    }
}
