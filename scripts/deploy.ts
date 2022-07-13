import { ethers, upgrades } from "hardhat";

async function main() {
  const MyTokenV1 = await ethers.getContractFactory("");

  const instance = await upgrades.deployProxy(MyTokenV1, { kind: "uups" });
  console.log("address := ", instance.address);
  console.log(Number.parseInt("0x"));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
