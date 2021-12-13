// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import {BaseStrategy} from "@badger-finance/BaseStrategy.sol";

contract MyStrategy is BaseStrategy {
// address public want; // Inherited from BaseStrategy
    // address public lpComponent; // Token that represents ownership in a pool, not always used
    // address public reward; // Token we farm

    address constant public BADGER = 0x3472A5A71965499acd81997a54BBA8D852C6E53d; 

    /// @notice set using setAutoCompoundRatio()
    // uint256 public autoCompoundRatio = 10_000; // Inherited from BaseStrategy - percentage of rewards converted to want

    /// @dev Initialize the Strategy with security settings as well as tokens
    /// @notice Proxies will set any non constant variable you declare as default value
    /// @dev add any extra changeable variable at end of initializer as shown
    /// @notice Dev must implement
    function initialize(address _vault, address[1] memory _wantConfig) public initializer {
        __BaseStrategy_init(_vault);
        /// @dev Add config here
        want = _wantConfig[0];

        autoCompoundRatio = 10_000; // Percentage of reward we reinvest into want

        // If you need to set new values that are not constants, set them like so
        // stakingContract = 0x79ba8b76F61Db3e7D994f7E384ba8f7870A043b7;

        // If you need to do one-off approvals do them here like so
        // IERC20Upgradeable(reward).safeApprove(
        //     address(DX_SWAP_ROUTER),
        //     type(uint256).max
        // );
    }

    function getName() external pure override returns (string memory) {
        return "DemoStrategy";
    }


    function getProtectedTokens() public view virtual override returns (address[] memory) {
        address[] memory protectedTokens = new address[](2);
        protectedTokens[0] = want;
        protectedTokens[1] = BADGER;
        return protectedTokens;
    }

    function _deposit(uint256 _amount) internal override {
        // No-op as we don't do anything
    }

    function _withdrawAll() internal override {
        // No-op as we don't deposit
    }

    function _withdrawSome(uint256 _amount) internal override returns (uint256) {
        return _amount;
    }

    function harvest() external override whenNotPaused returns (TokenAmount[] memory harvested) {
        _onlyAuthorizedActors();
        // No-op as we don't do anything with funds
        // use autoCompoundRatio here to convert rewards to want ...
        // keep this to get paid!
        // _reportToVault(earned);

        // Nothing harvested, we have 2 tokens, return both 0s
        harvested = new TokenAmount[](2);
        harvested[0] = TokenAmount(want, 0);
        harvested[1] = TokenAmount(BADGER, 0);
        return harvested;
    }

    /// @dev function to test harvest -
    // NOTE: want of 1 ether would be minted directly to DemoStrategy and this function would be called
    /// @param amount how much was minted to report
    function test_harvest(uint256 amount) external whenNotPaused returns (TokenAmount[] memory harvested) {
        _onlyAuthorizedActors();

        // Amount of want autocompounded after harvest in terms of want
        // keep this to get paid!
        _reportToVault(amount);

        harvested = new TokenAmount[](2);
        harvested[0] = TokenAmount(want, amount);
        harvested[1] = TokenAmount(BADGER, 0); // Nothing harvested for Badger
        return harvested;
    }

    function test_harvest_only_emit(address token, uint256 amount) external whenNotPaused returns (TokenAmount[] memory harvested){
        _onlyAuthorizedActors();

        // Note: This breaks if you don't send amount to the strat
        _processExtraToken(token, amount);

        harvested = new TokenAmount[](2);
        harvested[0] = TokenAmount(want, 0); // Nothing harvested for want
        harvested[1] = TokenAmount(BADGER, amount); 
        return harvested;
    }

    // Example tend is a no-op which returns the values, could also just revert
    function tend() external override returns (TokenAmount[] memory tended){
        // Nothing tended
        tended = new TokenAmount[](2);
        tended[0] = TokenAmount(want, 0);
        tended[1] = TokenAmount(BADGER, 0); 
        return tended;
    }

    function balanceOfPool() public view override returns (uint256) {
        return 0;
    }

    function balanceOfRewards() external view override returns (TokenAmount[] memory rewards) {
        // Rewards are 0
        rewards = new TokenAmount[](2);
        rewards[0] = TokenAmount(want, 0);
        rewards[1] = TokenAmount(BADGER, 0); 
        return rewards;
    }
}