var CoinVila = artifacts.require("./CoinVila.sol");
//import assertRevert from './helpers/assertRevert';

contract('CoinVila', (accounts) => {
    var contract;
    var owner = "0x9a98D8306fEcA891D052f1572ea18589004Be56c";
    var rate = 15*140;
    var buyWei = 5 * 10**17;
    var rateNew = 15*140;
    var buyWeiNew = 5 * 10**17;
    var buyWeiMin = 3 * 10**15;
    var buyWeiCap = 600 * 10**24;

    var maxTotalSupply = 7 * 10**6 * 10**18;

    it('should deployed contract', async ()  => {
        assert.equal(undefined, contract);
        contract = await CoinVila.deployed();
        assert.notEqual(undefined, contract);
    });

    it('get address contract', async ()  => {
        assert.notEqual(undefined, contract.address);
    });

    it('verification balance contract', async ()  => {
        var maxTotalSupplyTest = await contract.maxTotalSupply.call();
        //console.log(JSON.stringify(maxTotalSupplyTest));
        assert.equal(Number(maxTotalSupplyTest), maxTotalSupply);

        //var balanceOwner = await contract.balanceOf(owner);
        //console.log("balanceOwner = " + balanceOwner);
        //assert.equal(totalSupply, balanceOwner);
    });

/*
    it('verification date', async ()  => {
        var result = await contract.testDate.call();
        //console.log("result = " + result);
        assert.equal(true, result);
    });
*/


/*
    it('verification of receiving Ether', async ()  => {
        var tokenAllocatedBefore = await contract.tokenAllocated.call();
        var balanceAccountTwoBefore = await contract.balanceOf(accounts[2]);
        var weiRaisedBefore = await contract.weiRaised.call();
        //console.log("tokenAllocatedBefore = " + tokenAllocatedBefore);

        var numberToken = await contract.validPurchaseTokens.call(buyWei);
        //console.log(" numberTokens = " + JSON.stringify(numberToken));
        //console.log("numberTokens = " + numberToken);

        await contract.buyTokens(accounts[2],{from:accounts[2], value:buyWei});
        var tokenAllocatedAfter = await contract.tokenAllocated.call();
        //console.log("tokenAllocatedAfter = " + tokenAllocatedAfter);

        assert.isTrue(tokenAllocatedBefore < tokenAllocatedAfter);
        assert.equal(0, tokenAllocatedBefore);
        assert.equal(rate*buyWei, tokenAllocatedAfter);

        var balanceAccountTwoAfter = await contract.balanceOf(accounts[2]);
        assert.isTrue(balanceAccountTwoBefore < balanceAccountTwoAfter);
        assert.equal(0, balanceAccountTwoBefore);
        assert.equal(rate*buyWei, balanceAccountTwoAfter);

        var weiRaisedAfter = await contract.weiRaised.call();
        //console.log("weiRaisedAfter = " + weiRaisedAfter);
        assert.isTrue(weiRaisedBefore < weiRaisedAfter);
        assert.equal(0, weiRaisedBefore);
        assert.equal(buyWei, weiRaisedAfter);

        var depositedAfter = await contract.getDeposited.call(accounts[2]);
        //console.log("DepositedAfter = " + depositedAfter);
        assert.equal(buyWei, depositedAfter);

        var balanceAccountThreeBefore = await contract.balanceOf(accounts[3]);
        await contract.buyTokens(accounts[3],{from:accounts[3], value:buyWeiNew});
        var balanceAccountThreeAfter = await contract.balanceOf(accounts[3]);
        assert.isTrue(balanceAccountThreeBefore < balanceAccountThreeAfter);
        assert.equal(0, balanceAccountThreeBefore);
        //console.log("balanceAccountThreeAfter = " + balanceAccountThreeAfter);
        assert.equal(rateNew*buyWeiNew, balanceAccountThreeAfter);

        var balanceOwnerAfter = await contract.balanceOf(owner);
        //console.log("balanceOwnerAfter = " + Number(balanceOwnerAfter));
        //assert.equal(totalSupply - balanceAccountThreeAfter - balanceAccountTwoAfter, balanceOwnerAfter);


    });
*/

/*
    it('verification tokens limit min amount', async ()  => {
            var numberTokensMinWey = await contract.validPurchaseTokens.call(buyWeiMin);
            //console.log("numberTokensMinWey = " + numberTokensMinWey);
            assert.equal(0, numberTokensMinWey);
    });
*/

/*
    it('verification tokens cap reached', async ()  => {
            var numberTokensNormal = await contract.validPurchaseTokens.call(buyWei);
            //console.log("numberTokensNormal = " + numberTokensNormal);
            assert.equal(rate*buyWei, numberTokensNormal);

            var numberTokensFault = await contract.validPurchaseTokens.call(buyWeiCap);
            //console.log("numberTokensFault = " + numberTokensFault);
            assert.equal(0, numberTokensFault);
    });
*/

});



