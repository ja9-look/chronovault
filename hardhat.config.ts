import "@nomicfoundation/hardhat-toolbox"

import { HardhatUserConfig } from "hardhat/config"

import "hardhat-deploy"
import "@nomiclabs/hardhat-solhint"
import "hardhat-deploy"
import "solidity-coverage"

import "dotenv/config"

const config: HardhatUserConfig = {
	defaultNetwork: "hardhat",
	solidity: {
		compilers: [
			{
				version: "0.8.20",
			},
		],
	},
}

export default config