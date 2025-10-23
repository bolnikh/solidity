import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("MyICOModule", (m) => {
  const account0 = m.getAccount(0);

  const now = Math.floor(Date.now() / 1000);
  const now1 = now + 3600;
  const my_ico = m.contract("MyICO", [BigInt(0.001 * 1e18), BigInt(0.1 * 1e18), BigInt(1 * 1e18), now, now1], {from: account0});
  
  const my_token = m.call(my_ico, "deployToken", ["My Token", "MTK"]);
  
  return { my_ico };
});
