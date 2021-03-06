// SPDX-License-Identifier: AGPLv3
pragma solidity 0.7.6;

import {
    ISuperfluid,
    ISuperAgreement,
    ISuperfluidToken,
    ISuperToken,
    ISuperTokenFactory,
    ISuperfluidGovernance,
    SuperfluidGovernanceConfigs
} from "../interfaces/superfluid/ISuperfluid.sol";

import { UUPSProxiable } from "../upgradability/UUPSProxiable.sol";

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";


contract TestGovernance is
    Ownable,
    ISuperfluidGovernance
{

    mapping (bytes32 => uint256) private _configs;

    constructor(
        address rewardAddress,
        uint256 liquidationPeriod
    )
    {
        _configs[SuperfluidGovernanceConfigs.SUPERFLUID_REWARD_ADDRESS_CONFIG_KEY] = uint256(uint160(rewardAddress));
        _configs[SuperfluidGovernanceConfigs.CFAv1_LIQUIDATION_PERIOD_CONFIG_KEY] = liquidationPeriod;

        transferOwnership(msg.sender);
    }

    /**************************************************************************
    /* Configurations
    /*************************************************************************/

    function getRewardAddress() external view returns (address) {
        return address(int160(_configs[SuperfluidGovernanceConfigs.SUPERFLUID_REWARD_ADDRESS_CONFIG_KEY]));
    }

    function setRewardAddress(
        address rewardAddress
    )
        external
        onlyOwner
    {
        _configs[SuperfluidGovernanceConfigs.SUPERFLUID_REWARD_ADDRESS_CONFIG_KEY] = uint256(uint160(rewardAddress));
    }

    function setLiquidationPeriod(uint256 liquidationPeriod)
        external
        onlyOwner
    {
        _configs[SuperfluidGovernanceConfigs.CFAv1_LIQUIDATION_PERIOD_CONFIG_KEY] = liquidationPeriod;
    }

    function setTrustedForwarderAddress(address forwarder)
        external
        onlyOwner
    {
        _configs[SuperfluidGovernanceConfigs.BICONOMY_FORWARDER_ADDRESS_CONFIG_KEY] = uint256(uint160(forwarder));
    }

    /**************************************************************************
    /* ISuperfluidGovernance interface
    /*************************************************************************/

    function replaceGovernance(
        ISuperfluid host,
        address newGov
    )
        external override
        onlyOwner
    {
        host.replaceGovernance(ISuperfluidGovernance(newGov));
    }

    function registerAgreementClass(
        ISuperfluid host,
        address agreementClass
    )
        external override
        onlyOwner
    {
        host.registerAgreementClass(ISuperAgreement(agreementClass));
    }

    function updateContracts(
        ISuperfluid host,
        address hostNewLogic,
        address[] calldata agreementClassNewLogics,
        address superTokenFactoryNewLogic
    )
        external override
        onlyOwner
    {
        if (hostNewLogic != address(0)) {
            UUPSProxiable(address(host)).updateCode(hostNewLogic);
        }
        for (uint i = 0; i < agreementClassNewLogics.length; ++i) {
            host.updateAgreementClass(ISuperAgreement(agreementClassNewLogics[i]));
        }
        if (superTokenFactoryNewLogic != address(0)) {
            host.updateSuperTokenFactory(ISuperTokenFactory(superTokenFactoryNewLogic));
        }
    }

    function updateSuperTokenLogic(
        ISuperfluid host,
        ISuperToken token
    )
        external override
        onlyOwner
    {
        host.updateSuperTokenLogic(token);
    }

    function getConfigAsAddress(
        ISuperfluid /*host*/,
        ISuperfluidToken /* superToken */,
        bytes32 key
    )
        external view override
        returns(address value)
    {
        return address(int160(_configs[key]));
    }

    function getConfigAsUint256(
        ISuperfluid /*host*/,
        ISuperfluidToken /* superToken */,
        bytes32 key
    )
        external view override
        returns(uint256 period)
    {
        return _configs[key];
    }
}
