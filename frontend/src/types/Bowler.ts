export type Bowler = {
  bowlerId: number;
  bowlerLastName: string;
  bowlerFirstName: string;
  bowlerMiddleInit: string;
  bowlerAddress: string;
  bowlerCity: string;
  bowlerState: string;
  bowlerZip: number;
  bowlerPhoneNumber: string;
  team: {
    teamID: number;
    teamName: string;
  };
};
