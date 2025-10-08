import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("MyFirstTokenModule", (m) => {
  const mft = m.contract("MyFirstToken", ["My First Token", "MFT", 18, "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266"]);

  return { mft };
});
