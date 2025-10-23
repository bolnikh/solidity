import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("SimpleVotingModule", (m) => {

  const now = Math.floor(Date.now() / 1000);
  const simple_voting = m.contract("SimpleVoting", [3, now + 10, now + 100]);

  return { simple_voting };
});
