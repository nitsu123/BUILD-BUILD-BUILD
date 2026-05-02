/* SPDX-License-Identifier: GPL-3.0 */

pragma solidity >0.8.0 <=0.9.0;

contract AMM{
    address public owner;
    address public tokenA;
    address public tokenB;
    uint reserveA;
    uint reserveB;
    uint totalLiquidity;

    mapping(address => uint) public userLP;

    constructor() {
        owner = msg.sender;
    }


    function addLiuqidity(uint amountA, uint amountB) public {
        require(amountA > 0 && amountB > 0, "invalid amount");
        if(reserveA == 0 && reserveB == 0) {
            reserveA = amountA;
            reserveB = amountB;

            uint liquidity = amountA + reserveA;
            totalLiquidity += liquidity;
            userLP[msg.sender] += liquidity;
        }
        else {
            require(amountA * reserveB == amountB * reserveA, "invalid ratio");
            uint liquidity = (amountA * totalLiquidity) / reserveA;
            totalLiquidity += liquidity;
            userLP[msg.sender] += liquidity;  
        }
    }

    function swap(uint amountIn) public payable {
        amountIn = msg.value;
        uint confirmedIn = (amountIn * 990) / 1000;
        require(confirmedIn > 0, "invalid amount");

        uint oldA = reserveA;
        uint oldB = reserveB;

        uint newA = amountIn + oldA; 
        uint newB = (oldA * oldB) / newA;

        uint amountOut = newB - oldB;

        (bool success, ) = tokenB.call(abi.encodeWithSignature("transfer(address, uint)", msg.sender, amountOut));
        require(success, "transfer failed");
    }
    function withdrawLiquidity(uint _withdraw) public {
        require(_withdraw <= userLP[msg.sender], "insufficient amount");
        require(_withdraw > 0, "invalid amount");
        require(totalLiquidity > 0, "no liquidity to withdraw");
        uint lpAmount = _withdraw;

        uint ethOut = (lpAmount * reserveA) / totalLiquidity ;
        uint tokenOut = (reserveB * lpAmount) /  totalLiquidity ;

        reserveA -= ethOut;
        reserveB -= tokenOut;
        
        userLP[msg.sender] -= _withdraw;
        totalLiquidity -= _withdraw;

        (bool success, ) = (msg.sender).call{value: ethOut}("");
        require(success, "withdraw failed");
        (bool withdrawn, ) = (tokenB).call(abi.encodeWithSignature("transfer(address, uint)", msg.sender, tokenOut));
        require(withdrawn, "USDC withdraw failed");
    }

}

            
