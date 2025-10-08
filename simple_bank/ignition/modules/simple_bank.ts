import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("SimpleBankModule", (m) => {
  const simple_bank = m.contract("SimpleBank");

  return { simple_bank };
});
