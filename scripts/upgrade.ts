//@ts-ignore
import { ethers, upgrades } from "hardhat";

const proxy = "0xE0a3BEc4B892048b75E89Bb6bFBE0b86Db16326a"

async function main() {
  const BudXNFTControlV4 = await ethers.getContractFactory("BudXNFTControlV4");
  // const instance = await upgrades.deployProxy(BudXNFTControl, ["0x9399BB24DBB5C4b782C70c2969F58716Ebbd6a3b"], {
  //   kind: "uups",
  //   initializer: "initialize"
  // });
  const instance = await upgrades.upgradeProxy(proxy, BudXNFTControlV4);
  console.log("address := ", instance.address);
  // await upgrades.upgradeProxy(proxy, BudXNFTControl);
  // console.log("contract upgraded");
  //   const instance = await upgrades.deployProxy(BudTestV2, [100], {
  //     initializer: "initialize",
  //   });
  //   await instance.deployed();
  //   console.log("Box deployed to: ", instance.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
