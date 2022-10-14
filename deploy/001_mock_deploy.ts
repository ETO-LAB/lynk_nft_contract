import {DeployFunction} from 'hardhat-deploy/types';
import {HardhatRuntimeEnvironment} from "hardhat/types";
import {MockERC20} from "../typechain-types";


const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    // @ts-ignore
    const {deployments, ethers, getNamedAccounts} = hre;
    const {deploy} = deployments;

    const {deployer1} = await getNamedAccounts();

    await deploy('mock_usdt', {
        from: deployer1,
        args: ["MOCK USDT", "mUSDT", 18],
        log: true,
        contract: "MockERC20"
    });

    await deploy('mock_ap_token', {
        from: deployer1,
        args: ["MOCK Attribute Point", "mAP", 18],
        log: true,
        contract: "MockERC20"
    });

    await deploy('mock_lynk_token', {
        from: deployer1,
        args: ["MOCK LYNK TOKEN", "mLYNK", 18],
        log: true,
        contract: "MockERC20"
    });


};
export default func;
func.tags = ['MockERC20'];
