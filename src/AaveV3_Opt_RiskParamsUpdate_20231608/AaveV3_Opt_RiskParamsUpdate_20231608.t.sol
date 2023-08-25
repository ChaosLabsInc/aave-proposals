// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {GovHelpers} from 'aave-helpers/GovHelpers.sol';
import {AaveGovernanceV2} from 'aave-address-book/AaveGovernanceV2.sol';
import {AaveV3Optimism, AaveV3OptimismAssets} from 'aave-address-book/AaveV3Optimism.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/ProtocolV3TestBase.sol';
import {AaveV3_Opt_RiskParamsUpdate_20231608} from './AaveV3_Opt_RiskParamsUpdate_20231608.sol';

/**
 * @dev Test for AaveV3_Opt_RiskParamsUpdate_20231608
 * command: make test-contract filter=AaveV3_Opt_RiskParamsUpdate_20231608
 */
contract AaveV3_Opt_RiskParamsUpdate_20231608_Test is ProtocolV3TestBase {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('optimism'), 108292954);
  }

  function testProposalExecution() public {
    AaveV3_Opt_RiskParamsUpdate_20231608 proposal = new AaveV3_Opt_RiskParamsUpdate_20231608();

    ReserveConfig[] memory allConfigsBefore = createConfigurationSnapshot(
      'preAaveV3_Opt_RiskParamsUpdate_20231608',
      AaveV3Optimism.POOL
    );

    GovHelpers.executePayload(vm, address(proposal), AaveGovernanceV2.OPTIMISM_BRIDGE_EXECUTOR);

    ReserveConfig[] memory allConfigsAfter = createConfigurationSnapshot(
      'postAaveV3_Opt_RiskParamsUpdate_20231608',
      AaveV3Optimism.POOL
    );

    // WBTC
    ReserveConfig memory WBTC_UNDERLYING_CONFIG = _findReserveConfig(
      allConfigsBefore,
      AaveV3OptimismAssets.WBTC_UNDERLYING
    );

    WBTC_UNDERLYING_CONFIG.liquidationBonus = 107_50;

    _validateReserveConfig(WBTC_UNDERLYING_CONFIG, allConfigsAfter);

    // wstETH
    ReserveConfig memory WSTETH_UNDERLYING_CONFIG = _findReserveConfig(
      allConfigsBefore,
      AaveV3OptimismAssets.wstETH_UNDERLYING
    );

    WSTETH_UNDERLYING_CONFIG.liquidationThreshold = 80_00;

    WSTETH_UNDERLYING_CONFIG.ltv = 71_00;

    _validateReserveConfig(WSTETH_UNDERLYING_CONFIG, allConfigsAfter);

    diffReports(
      'preAaveV3_Opt_RiskParamsUpdate_20231608',
      'postAaveV3_Opt_RiskParamsUpdate_20231608'
    );

    e2eTest(AaveV3Optimism.POOL);
  }
}
