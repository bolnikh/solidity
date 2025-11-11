import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("SignBill", (m) => {
  const counter = m.contract("SignBill", []);

  return { counter };
});
