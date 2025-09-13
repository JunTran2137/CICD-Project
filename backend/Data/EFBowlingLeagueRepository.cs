using Microsoft.EntityFrameworkCore;

namespace Backend.Data {
    public class EFBowlingLeagueRepository : IBowlingLeagueRepository {
        private BowlingLeagueContext _bowlingContext;

        public EFBowlingLeagueRepository(BowlingLeagueContext temp) { _bowlingContext = temp; }

        public IEnumerable<Bowler> Bowlers => _bowlingContext.Bowlers.Include(x => x.Team).ToList();

        public IEnumerable<BowlerScore> Scores => _bowlingContext.Scores;

        public IEnumerable<MatchGame> MatchGames => _bowlingContext.MatchGames;

        public IEnumerable<Team> Teams => _bowlingContext.Teams;

        public IEnumerable<Tournament> Tournaments => _bowlingContext.Tournaments;

        public IEnumerable<TourneyMatch> TourneyMatches => _bowlingContext.TourneyMatches;

        public IEnumerable<ZtblBowlerRating> ZtblBowlerRatings => _bowlingContext.ZtblBowlerRatings;

        public IEnumerable<ZtblSkipLabel> ZtblSkipLabels => _bowlingContext.ZtblSkipLabels;

        public IEnumerable<ZtblWeek> ZtblWeek => _bowlingContext.ZtblWeeks;
    }
}
