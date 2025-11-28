import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("ElectionModule", (m) => {
  const owner = m.getAccount(0);

  const election = m.contract("Election", [owner]);

  return { election };
});
