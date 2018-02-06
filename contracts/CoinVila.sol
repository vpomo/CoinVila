pragma solidity ^0.4.18;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    function Ownable() public {
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) internal onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }

}
/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}
/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
/**
 * @title PoSTokenStandard
 * @dev the interface of PoSTokenStandard
 */
contract PoSTokenStandard {
    uint256 public stakeStartTime;
    uint256 public stakeMinAge;
    uint256 public stakeMaxAge;
    //Accelerator - Modified the correct technical term "mint" to a well know term "mine" for marketing purposes
    function mine() public  returns (bool);
    function coinAge(address who) public  returns (uint256);
    function annualInterest() public  returns (uint256);
    event Mine(address indexed _address, uint _reward);
}

contract CoinVila is ERC20,PoSTokenStandard,Ownable {
    using SafeMath for uint256;
    //Accelerator - Changed name of contract
    string public name = "CoinVila";
    string public symbol = "VILA";
    uint public decimals = 18;

    uint public chainStartTime; //chain start time
    uint public chainStartBlockNumber; //chain start block number
    uint public stakeStartTime; //stake start time
    uint public stakeMinAge = 3 days; // minimum age for coin age: 3D
    uint public stakeMaxAge = 90 days; // stake age of full weight: 90D
    uint public maxMintProofOfStake = 10**17; // default 10% annual interest

    uint public totalSupply;
    uint public maxTotalSupply;
    uint public totalInitialSupply;

    struct transferInStruct{
        uint128 amount;
        uint64 time;
    }

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    mapping(address => transferInStruct[]) transferIns;

    //Accelerator - Removed burn system
    //event Burn(address indexed burner, uint256 value);

    /**
     * @dev Fix for the ERC20 short address attack.
     */
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4);
        _;
    }

    modifier canPoSMint() {
        require(totalSupply < maxTotalSupply);
        _;
    }

    function CoinVila(address _owner) public {
        require(_owner != address(0));
        owner = _owner;
        CoinVilaStart();
    }

    function CoinVilaStart() private {
        address recipient;
        uint value;
        uint64 _now = uint64(now);
        //kill start if this has already been ran
        require((maxTotalSupply <= 0));

        maxTotalSupply = 7 * 10**6 * 10**decimals; // 7 Mil.

        //Accelerator - Modified initial supply to 250k
        totalInitialSupply = 200 * 10**3 * 10**decimals; // 250K

        chainStartTime = now;
        chainStartBlockNumber = block.number;

/*
        //Free Airdrop to Affiliates and Website Visitors - 200K
        recipient = 0xFd3fBD60f3d394374d692C0cb7E3B90f064009b0;
        value = 2 * (10**23);
        //run
        balances[recipient] = value;
        transferIns[recipient].push(transferInStruct(uint128(value),_now));

        //Core development Team - 50K
        recipient = 0x347fdeCA4F170E59CE54AE63D2a841BCb39d3062;
        value = 5 * (10**22);
        //run
        balances[recipient] = value;
        transferIns[recipient].push(transferInStruct(uint128(value),_now));
*/

        totalSupply = totalInitialSupply;
    }

    function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool) {
        //Accelerator - Modified to mine
        if(msg.sender == _to) return mine();
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        if(transferIns[msg.sender].length > 0) delete transferIns[msg.sender];
        uint64 _now = uint64(now);
        transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),_now));
        transferIns[_to].push(transferInStruct(uint128(_value),_now));
        return true;
    }

    function balanceOf(address _owner) public returns (uint256 balance) {
        return balances[_owner];
    }

    function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) public returns (bool) {
        require(_to != address(0));

        var _allowance = allowed[_from][msg.sender];

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // require (_value <= _allowance);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        if(transferIns[_from].length > 0) delete transferIns[_from];
        uint64 _now = uint64(now);
        transferIns[_from].push(transferInStruct(uint128(balances[_from]),_now));
        transferIns[_to].push(transferInStruct(uint128(_value),_now));
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    //Accelerator - Modified the correct technical term "mint" to a well know term "mine" for marketing purposes.
    function mine() canPoSMint public returns (bool) {
        if(balances[msg.sender] <= 0) return false;
        if(transferIns[msg.sender].length <= 0) return false;

        uint reward = getProofOfStakeReward(msg.sender);
        if(reward <= 0) return false;

        totalSupply = totalSupply.add(reward);
        balances[msg.sender] = balances[msg.sender].add(reward);
        delete transferIns[msg.sender];
        transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),uint64(now)));
        //Accelerator - Change event to Mine
        Mine(msg.sender, reward);
        return true;
    }

    function getBlockNumber() public view returns (uint blockNumber) {
        blockNumber = block.number.sub(chainStartBlockNumber);
    }

    function coinAge(address who) public returns (uint myCoinAge) {
        myCoinAge = getCoinAge(who,now);
    }

    function annualInterest() public returns(uint interest) {
        uint _now = now;
        interest = maxMintProofOfStake;
        //Accelerator - Modified initial interest rate to 300%
        if((_now.sub(stakeStartTime)).div(1 years) == 0) {
            interest = (1650 * maxMintProofOfStake).div(100);
        } else if((_now.sub(stakeStartTime)).div(1 years) == 1) {
            interest = (770 * maxMintProofOfStake).div(100);
        } else if((_now.sub(stakeStartTime)).div(1 years) == 2){
            interest = (435 * maxMintProofOfStake).div(100);
        }
    }

    function getProofOfStakeReward(address _address) internal view returns (uint) {
        require( (now >= stakeStartTime) && (stakeStartTime > 0) );

        uint _now = now;
        uint _coinAge = getCoinAge(_address, _now);
        if(_coinAge <= 0) return 0;

        uint interest = maxMintProofOfStake;
        // Due to the high interest rate for the first two years, compounding should be taken into account.
        // Effective annual interest rate = (1 + (nominal rate / number of compounding periods)) ^ (number of compounding periods) - 1
        //Accelerator - Modified initial interest rate to 300%
        if((_now.sub(stakeStartTime)).div(1 years) == 0) {
            // 1st year effective annual interest rate is 300% when we select the stakeMaxAge (90 days) as the compounding period.
            interest = (1650 * maxMintProofOfStake).div(100);
        } else if((_now.sub(stakeStartTime)).div(1 years) == 1) {
            // 2nd year effective annual interest rate is 100% when we select the stakeMaxAge (90 days) as the compounding period.
            interest = (770 * maxMintProofOfStake).div(100);
        } else if((_now.sub(stakeStartTime)).div(1 years) == 2){
            // 3nd year effective annual interest rate is 50%
            interest = (435 * maxMintProofOfStake).div(100);
        }

        return (_coinAge * interest).div(365 * (10**decimals));
    }

    function getCoinAge(address _address, uint _now) internal view returns (uint _coinAge) {
        if(transferIns[_address].length <= 0) return 0;

        for (uint i = 0; i < transferIns[_address].length; i++){
            if( _now < uint(transferIns[_address][i].time).add(stakeMinAge) ) continue;

            uint nCoinSeconds = _now.sub(uint(transferIns[_address][i].time));
            if( nCoinSeconds > stakeMaxAge ) nCoinSeconds = stakeMaxAge;

            _coinAge = _coinAge.add(uint(transferIns[_address][i].amount) * nCoinSeconds.div(1 days));
        }
    }

    function ownerSetStakeStartTime(uint timestamp) public onlyOwner {
        require((stakeStartTime <= 0) && (timestamp >= chainStartTime));
        stakeStartTime = timestamp;
    }

    /**
    * Peterson's Law Protection
    * Claim tokens
    */
    function claimTokens() public onlyOwner {
        uint256 balance = balanceOf(this);
        transfer(owner, balance);
        Transfer(this, owner, balance);
        owner.transfer(this.balance);
    }

}
