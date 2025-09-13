namespace Backend.Data {
    public interface IBowlingLeagueRepository {
        IEnumerable<Bowler> Bowlers { get; }

        IEnumerable<BowlerScore> Scores { get; }

        IEnumerable<MatchGame> MatchGames { get; }

        IEnumerable<Team> Teams { get; }

        IEnumerable<Tournament> Tournaments { get; }

        IEnumerable<TourneyMatch> TourneyMatches { get; }

        IEnumerable<ZtblBowlerRating> ZtblBowlerRatings { get; }

        IEnumerable<ZtblSkipLabel> ZtblSkipLabels { get; }

        IEnumerable<ZtblWeek> ZtblWeek { get; }
    }
}
