import { HardhatUserConfig } from 'hardhat/config'
import '@nomiclabs/hardhat-waffle'
import '@nomiclabs/hardhat-ethers'
import 'solidity-coverage'
import '@nomicfoundation/hardhat-foundry'

const config: HardhatUserConfig = {
    solidity: '0.8.18',
}

export default config
