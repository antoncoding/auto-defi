pragma solidity ^0.5.0;


import "./ExchangeProxy.sol";
import "../uniswap/IUniswapExchange.sol";
import "../uniswap/IUniswapFactory.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";


/**
 * @dev Automatically split funds, exchange them to ERC20s upon receival.
 */
contract UniswapProxy is ExchangeProxy {
    using SafeMath for uint;

    mapping(address=>uint8) thresholds;
    IUniswapFactory factory;

    constructor(address _factory) public {
        factory = IUniswapFactory(_factory);
    }

    function split(address _targetToken, address _recipient) external payable {
        IUniswapExchange exchange = IUniswapExchange(factory.getExchange(_targetToken));
        // solium-disable-next-line security/no-tx-origin
        uint256 minToken = exchange.getEthToTokenInputPrice(msg.value).mul(thresholds[tx.origin]).div(100);
        uint256 deadline = (now + 1 hours).mul(1000);
        exchange.ethToTokenTransferInput.value(msg.value)(minToken, deadline, _recipient);
    }

}