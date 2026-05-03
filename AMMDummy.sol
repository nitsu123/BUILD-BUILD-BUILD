// SPDX-License-Identifier: GPL-3.0

pragma solidity >0.8.0 <=0.9.0;

contract AMM {
    address public owner;
    address public tokenA;
    address public tokenB;
    uint reserveA;
    uint reserveB;
    uint totalLiquidity;
    
    event LiquidityAdded(uint AmountA, uint AmountB, address LiquidityProvider);
    event Swapped(uint AmountSwapped, address Swapper);
    event LiquidityWithdrawn(uint AmountA, uint AmountB, address LiquidityProvider);


    mapping(address => uint) public userLP;

    constructor() {
        owner = msg.sender;
    }

    function addLiquidity(uint amountA, uint amountB) public payable {
        if(reserveA == 0 && reserveB == 0) {
            reserveA = amountA;
            reserveB = amountB;

            uint liquidity = amountA + amountB;
            totalLiquidity += liquidity;
            userLP[msg.sender]+= liquidity;
        }
        else {
            require(reserveA * amountB == reserveB * amountA);
                reserveA += amountA;
                reserveB += amountB;

                uint liquidity = (amountA * totalLiquidity) / reserveA;
                totalLiquidity += liquidity;
                userLP[msg.sender] += liquidity;
            }
        (bool success, ) = (tokenB).call(abi.encodeWithSignature("transfer(address, uint, uint)", msg.sender, amountA, amountB));
        require(success, "add liq failed");
        emit LiquidityAdded(amountA, amountB, msg.sender);
        }
    

        function swap() public payable {
            require(reserveA > 0 && reserveB > 0, "not enough liquidity");
            uint countedIn = (msg.value * 999) / 1000;  
            
            uint oldA = reserveA;
            uint oldB = reserveB;


            uint newA = countedIn + oldA;
            uint newB = (oldA * oldB) / newA;

            reserveA = newA;
            reserveB = newB;

            uint amountOut = oldB - newB;


            (bool success, ) = (tokenB).call(abi.encodeWithSignature("transfer(address, uint)", msg.sender, amountOut));
            require(success, "swap failed");


            emit Swapped(amountOut, msg.sender);
        }

    function withdrawShare(uint _withdraw) public payable {
        require(_withdraw > 0, "invalid amount");
        require(userLP[msg.sender] >= _withdraw, "you don not have any share");


        uint lpAmount = _withdraw;

        userLP[msg.sender] -= lpAmount;
        totalLiquidity -= lpAmount;

        uint ethOut = ( lpAmount * reserveA) / totalLiquidity;
        uint tokenOut = ( lpAmount * reserveB) /  totalLiquidity;

        reserveA -= ethOut;
        reserveB -= tokenOut;

        (bool success, ) = payable(msg.sender).call{value: ethOut}("");
        require(success,"withdraw failed");

        (bool withdrawn, ) = payable(tokenB).call(abi.encodeWithSignature("transfer(address, uint)", msg.sender, tokenOut));
        require(withdrawn, "withdraw failed");

        emit LiquidityWithdrawn(ethOut, tokenOut, msg.sender);
    }


}// SPDX-License-Identifier: GPL-3.0

pragma solidity >0.8.0 <=0.9.0;

contract AMM {
    address public owner;
    address public tokenA;
    address public tokenB;
    uint reserveA;
    uint reserveB;
    uint totalLiquidity;
    
    event LiquidityAdded(uint AmountA, uint AmountB, address LiquidityProvider);
    event Swapped(uint AmountSwapped, address Swapper);
    event LiquidityWithdrawn(uint AmountA, uint AmountB, address LiquidityProvider);


    mapping(address => uint) public userLP;

    constructor() {
        owner = msg.sender;
    }

    function addLiquidity(uint amountA, uint amountB) public payable {
        if(reserveA == 0 && reserveB == 0) {
            reserveA = amountA;
            reserveB = amountB;

            uint liquidity = amountA + amountB;
            totalLiquidity += liquidity;
            userLP[msg.sender]+= liquidity;
        }
        else {
            require(reserveA * amountB == reserveB * amountA);
                reserveA += amountA;
                reserveB += amountB;

                uint liquidity = (amountA * totalLiquidity) / reserveA;
                totalLiquidity += liquidity;
                userLP[msg.sender] += liquidity;
            }
        (bool success, ) = (tokenB).call(abi.encodeWithSignature("transfer(address, uint, uint)", msg.sender, amountA, amountB));
        require(success, "add liq failed");
        emit LiquidityAdded(amountA, amountB, msg.sender);
        }
    

        function swap() public payable {
            require(reserveA > 0 && reserveB > 0, "not enough liquidity");
            uint countedIn = (msg.value * 999) / 1000;  
            
            uint oldA = reserveA;
            uint oldB = reserveB;


            uint newA = countedIn + oldA;
            uint newB = (oldA * oldB) / newA;

            reserveA = newA;
            reserveB = newB;

            uint amountOut = oldB - newB;


            (bool success, ) = (tokenB).call(abi.encodeWithSignature("transfer(address, uint)", msg.sender, amountOut));
            require(success, "swap failed");


            emit Swapped(amountOut, msg.sender);
        }

    function withdrawShare(uint _withdraw) public payable {
        require(_withdraw > 0, "invalid amount");
        require(userLP[msg.sender] >= _withdraw, "you don not have any share");


        uint lpAmount = _withdraw;

        userLP[msg.sender] -= lpAmount;
        totalLiquidity -= lpAmount;

        uint ethOut = ( lpAmount * reserveA) / totalLiquidity;
        uint tokenOut = ( lpAmount * reserveB) /  totalLiquidity;

        reserveA -= ethOut;
        reserveB -= tokenOut;

        (bool success, ) = payable(msg.sender).call{value: ethOut}("");
        require(success,"withdraw failed");

        (bool withdrawn, ) = payable(tokenB).call(abi.encodeWithSignature("transfer(address, uint)", msg.sender, tokenOut));
        require(withdrawn, "withdraw failed");

        emit LiquidityWithdrawn(ethOut, tokenOut, msg.sender);
    }


}
