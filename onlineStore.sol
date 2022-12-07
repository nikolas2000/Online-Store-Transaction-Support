// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.13 < 0.9;

//That's the contract that the customer uses to place holders, pay, etc...
contract CustomerContract 
{
    struct AdminAccount //That struct describes an Admin's account
    {
        string name;
        address accountAddress;
        
    }
    struct OrderDetails //That struct describes an Order.
    {
        uint paymentAmount; //the money of the order
        string order_State; //Shows the order's state: "Waiting acceptance" or "Denied" or "Acceptance" or "Requested money back" or "Denied money back".
       
    }
    AdminAccount adminAccount1 = AdminAccount("Nick",0x507e872770131C4D5aD8c61Da33eDBdE4e1cA480); //Metamask accounts.
    AdminAccount adminAccount2 = AdminAccount("Maria",0x5993705065d7ba30D861bd900FCfC584Ca6d9959);
    AdminAccount adminAccount3 = AdminAccount("Eleni",0x82238ec9C37eB9c806E3a6761cA27204263D8Ad9); 
     
    mapping (uint8 => AdminAccount) adminsMap; //has all the admins
    mapping (uint8 => bool) votesPaymentMap; //What every admin voted
    mapping (uint8 => bool) votesToChangeAdmin1Map; //what admin2 and admin3 voted to change admin1
    mapping (uint8 => bool) votesToChangeAdmin2Map; //what admin1 and admin3 voted to change admin2
    mapping (uint8 => bool) votesToChangeAdmin3Map; //what admin1 and admin2 voted to change admin3

    mapping (string => OrderDetails) public ordersMap; //has all the orders

    
    address payable paymentContractAddress; //the address of the payment contract
    address payable shopContractAddress;//the address of the shop contract
    
    ShopContract shopContract; //We created it in order to use the methods of the ShopContract. (It's like an object)

    constructor() payable
    {      
        //We add the admins to the map
    adminsMap[1]=adminAccount1;
    adminsMap[2]=adminAccount2;
    adminsMap[3]=adminAccount3;

//At first all the votes are negative.
    initiatePaymentVotes();
    initiateChangeAdmin1Votes();
    initiateChangeAdmin2Votes();
    initiateChangeAdmin3Votes();
    }

    

//The 4 functions below convert all the votes as negative. That's happing after a task (payment,account change) is completed and the
//votes must be false again or at the creation of the smart contract when the admins have not voted yet.

    function initiatePaymentVotes() private //Initiate the payment-votes
    { //At first all the votes are negative (false). False means either the admin hasn't voted yet or he voted no.
    votesPaymentMap[1]=false;
    votesPaymentMap[2]=false;
    votesPaymentMap[3]=false;
   
    }
//Initiate the votes about the change of one admin account by the other 2 admins.
    function initiateChangeAdmin1Votes() private 
    {
        //At first the voted are equal to zero, as noone has voted yet.
        //If the number of negative votes is equal to 2, then the admin account changes
    votesToChangeAdmin1Map[2]=false;
    votesToChangeAdmin1Map[3]=false;
    }
    function initiateChangeAdmin2Votes() private
    {
        //At first the voted are equal to zero, as noone has voted yet.
        //If the number of negative votes is equal to 2, then the admin account changes 
    votesToChangeAdmin2Map[1]=false;
    votesToChangeAdmin2Map[3]=false;
    }
    function initiateChangeAdmin3Votes() private 
    {
        //At first the voted are equal to zero, as noone has voted yet.
        //If the number of negative votes is equal to 2, then the admin account changes 
    votesToChangeAdmin3Map[1]=false;
    votesToChangeAdmin3Map[2]=false;
    }



    /*This fuction is used to check if the transaction is agreed by the admin-accounts 
    if the number of approvements is greater than 2 it returns true, else it returns false. */
    function checkTransactionApprovements() public view returns(uint8)
    {
        uint8 i;
        uint8 numberOfApproves;
        for (i=1;i<=3;i+=1)
        {
            if(votesPaymentMap[i]==true)
            {
                numberOfApproves+=1;
            }
           
        }
       return (numberOfApproves);
        
    }

//That function lets the admins vote if they want the payment to be succeeded.
    function voteForPayment(uint8 adminID, bool preference)   public 
    {
        require(adminID==1 || adminID==2 || adminID==3, "That admin does not exist! (Existed adminsIDs: 1,2 and 3)");
        
            
        votesPaymentMap[adminID]=preference;
                        

    }



//That function lets the admins change their account with another one.
function changeAdminAccountItself(uint8 adminID,string memory newName, address newAccountAddress) public
{
    require(adminID==1 || adminID==2 || adminID==3, "That admin does not exist! (Existed adminsIDs: 1,2 and 3)");
    adminsMap[adminID].name=newName;
    adminsMap[adminID].accountAddress=newAccountAddress;

   
}

//That function checks if there are enough approvements to change an account by the others
function checkIfAccountChangesByOthers(uint8 adminToChangeID) public view returns(uint8)
{
    require(adminToChangeID==1 || adminToChangeID==2 || adminToChangeID==3, "That admin does not exist! (Existed adminsIDs: 1,2 and 3)");
    uint8 numberOfApproves=0;
    uint8 firstVoterID = 2;
    uint8 secondVoterID =3;
    mapping (uint8 => bool) storage votesToChangeAdmin = votesToChangeAdmin1Map;
    if(adminToChangeID==2)
       {
           firstVoterID=1;
           secondVoterID =3;
         votesToChangeAdmin=votesToChangeAdmin2Map;
       } 
       else if(adminToChangeID==3)
       {
           firstVoterID=1;
           secondVoterID=2;
           votesToChangeAdmin=votesToChangeAdmin3Map;
       }
    
    if(votesToChangeAdmin[firstVoterID]==true)
    {
        numberOfApproves+=1;
    }
    if(votesToChangeAdmin[secondVoterID]==true)
    {
        numberOfApproves+=1;
    }

    return numberOfApproves;
}

//If there number of votes to change an admin is more or equal to 2, then the admin-account changes
function changeAccountChangesByOthers(uint8 adminToChangeID,string memory newNameAdmin, address newAddressAdmin) public returns(uint8)
{
    require(adminToChangeID==1 || adminToChangeID==2 || adminToChangeID==3, "That admin does not exist! (Existed adminsIDs: 1,2 and 3)");
    uint8 numberOfApproves=checkIfAccountChangesByOthers(adminToChangeID);

    require(numberOfApproves==2,"Not enough votes!");
    AdminAccount memory newAdminAccount = AdminAccount(newNameAdmin,newAddressAdmin);
    adminsMap[adminToChangeID]=newAdminAccount;
    
    //We initialize again those votes(set them false).
    if(adminToChangeID==1)
    {
        initiateChangeAdmin1Votes();
    }
    else if(adminToChangeID==2)
    {
        initiateChangeAdmin2Votes();
    }
    else
    {
        initiateChangeAdmin3Votes();
    }
    return numberOfApproves;

}

//The function that lets an admin to vote to change other admin. Preference: true => He wants, false=> He doen't want.
function voteForOtherAccountChange(uint8 admin_voterID ,uint8 adminToChangeID, bool preference)   public 
    {
        require(admin_voterID!=adminToChangeID,"The admin_voterID must not be equal to adminToChangeID");
        require(admin_voterID==1 || admin_voterID==2 || admin_voterID==3,"That admin_voterID does not exist! (Existed adminsIDs: 1,2 and 3)");
        require(adminToChangeID==1 || adminToChangeID==2 || adminToChangeID==3, "That adminToChangeID does not exist! (Existed adminsIDs: 1,2 and 3)");
        
        if(adminToChangeID==1)
        {
            votesToChangeAdmin1Map[admin_voterID]=preference;
        }
        if(adminToChangeID==2)
        {
            votesToChangeAdmin2Map[admin_voterID]=preference;
        }
        if(adminToChangeID==3)
        {
            votesToChangeAdmin3Map[admin_voterID]=preference;
        }
                                     

    }

//Shows the account details of a specific account according to its id. It is used to ensure that an account is indeed changed. 
    function showAdmin(uint8 admin_ID) public view returns(string memory,address)
    {
        require(admin_ID==1 || admin_ID==2 || admin_ID==3, "That admin does not exist! (Existed adminsIDs: 1,2 and 3)");
        string memory name = adminsMap[admin_ID].name;
        address account_Address = adminsMap[admin_ID].accountAddress;
        return (name,account_Address);
    }


//The fuction which is used to pay an amount to the PaymentContract for an order.
    function pay(string memory order_ID, uint payment_amount) external payable 
    {
        

        uint8 numberOfApproves = checkTransactionApprovements();
                  
        require(numberOfApproves>=2,"The transaction has not been approved!");

                
        placeHolder(order_ID,payment_amount);

        
        //After the payment, all the votes are false again for the next payment.
        initiatePaymentVotes();
    }

//That's a private function that is call into the pay-function and sends money to the paymentContract and sets the
//order's details to the shopContract.
    function placeHolder(string memory order_ID,uint payment_amount) private
    {
        //address payable to_addressPaymentContract = payable(addressPaymentContract);
        paymentContractAddress.transfer(payment_amount);
        shopContract.setOrderDetails(order_ID,payment_amount,msg.sender,address(this),paymentContractAddress);

        OrderDetails memory newOrder=OrderDetails(payment_amount,"Waiting acceptance"); //at first the state on waiting mode.
        ordersMap[order_ID]=newOrder; //we add to the customer's orders
    }
    
    //That function should be first at first and initiates the addresses of the other 2 contracts.
    //***That's important function** Without it the program cannot run correctly.
    function setAddressOfTheOtherContracts(address addressPaymentContract,address addressShopContract) public 
    {
       paymentContractAddress=payable(addressPaymentContract);
    
       shopContractAddress=payable(addressShopContract);
       shopContract=ShopContract(payable(addressShopContract));
        
    }
    
    //With that function the user is informed by the shop about the state of his order.
    function getStorePaymentState(string memory order_ID)  public 
    {
                
        ordersMap[order_ID].order_State=shopContract.showPaymentState(order_ID);
    }
    //That function shows the state of the order. 
    function showStorePaymentState(string memory order_ID) public view returns (string memory)
    {
                       
        return ordersMap[order_ID].order_State;
    }
   
   //If the order is under waiting mode, the customer can cancel his order and get his money back.
   function getMoneyBackWhileWaiting(string memory order_ID) public
   {
      shopContract.setPaymentState(order_ID,false); //calls that function with false, so as to cancel the order.
   }


    //The customer can request his money after the acceptance of his payment and wait the response of the shop.
    function requestMoneyAfterAcceptance(string memory order_ID) public
    {
        shopContract.setOrderUnderRequest(order_ID);
    }

    
     
    receive() external payable {}
    
    fallback() external payable {}
}



//That's the contract that has all the functionalities of the Shop. It approves or disapproves orders, sends money back, etc...
contract ShopContract
{
    
    address payable paymentContract_Address; //the address of the paymentContract

    struct OrderDetails //That struct describes an Order
    {
        uint paymentAmount; //the money of the order
        string order_State; //Shows the order's state: "Waiting acceptance" or "Denied" or "Acceptance" or "Requested money back" or "Denied money back".
        address customerAccountAddress;//customer's account addresses
        address customerContractAddress; //customer's contract address
        
    }
   

    mapping(string => OrderDetails) allOrdersMap; //contains all the orders.

//Sets the order details.
    function setOrderDetails(string memory order_ID,uint payment_amount,address customerAccountAddress,address customerContractAddress,address paymentContractAddress) public
    {
           
        
        OrderDetails memory newOrder = OrderDetails(payment_amount,"Waiting acceptance",customerAccountAddress,customerContractAddress);//At first an order is on a waiting mode.
        allOrdersMap[order_ID]=newOrder;
        paymentContract_Address=payable(paymentContractAddress);

    }


    //shows the state of an order (payment).
    function showPaymentState(string memory order_ID) public view returns (string memory)
    {
        string memory paymentState=allOrdersMap[order_ID].order_State;
        return paymentState;
    }

    //sets the state of a payment. If accepted-->the shop is payed. If denied-->sends money back.
    function setPaymentState(string memory order_ID,bool isAccepted) external payable 
    {
        require(keccak256(abi.encodePacked(allOrdersMap[order_ID].order_State))==keccak256(abi.encodePacked("Waiting acceptance")),"That order is not in waiting mode.");
        
        PaymentContract paymentContract=PaymentContract(payable(paymentContract_Address));
        if(isAccepted==true)
        {
            allOrdersMap[order_ID].order_State="Accepted";
            
            paymentContract.payFunction(payable(address(this)),allOrdersMap[order_ID].paymentAmount);
        }
        else
        {
            allOrdersMap[order_ID].order_State="Denied";
            paymentContract.payFunction(payable(allOrdersMap[order_ID].customerAccountAddress),allOrdersMap[order_ID].paymentAmount);
        }

        CustomerContract customer = CustomerContract(payable(allOrdersMap[order_ID].customerContractAddress));
        customer.getStorePaymentState(order_ID); //informs the customer about his payment state
    }

//shows the state of an order.
    function showOrder(string memory order_ID) public view returns(string memory,uint)
    {        
        uint  money = allOrdersMap[order_ID].paymentAmount;
        string memory state = allOrdersMap[order_ID].order_State;
        return (state,money);
    }

//That function is called from the customer in order to ask his money back.
    function setOrderUnderRequest(string memory order_ID) public
    {
         require(keccak256(abi.encodePacked(allOrdersMap[order_ID].order_State))==keccak256(abi.encodePacked("Accepted")),"Not Accepted payment.");
        allOrdersMap[order_ID].order_State="Requested money back";
        CustomerContract customer = CustomerContract(payable(allOrdersMap[order_ID].customerContractAddress));
        customer.getStorePaymentState(order_ID); //informs the sutomer about his payment state
    }
    //That function is called from the shop in order to approve or disapprove customer's request.
    function answerRequest(string memory order_ID,bool approve) public
    {
        require(keccak256(abi.encodePacked(allOrdersMap[order_ID].order_State))==keccak256(abi.encodePacked("Requested money back")),"No requests for this order.");

        if(approve==true)
        {
             (payable(allOrdersMap[order_ID].customerAccountAddress)).transfer(allOrdersMap[order_ID].paymentAmount);
             allOrdersMap[order_ID].order_State="Approved money back";
        }
        else
        {
            allOrdersMap[order_ID].order_State="Denied money back";
        }
        CustomerContract customer = CustomerContract(payable(allOrdersMap[order_ID].customerContractAddress));
        customer.getStorePaymentState(order_ID); //informs the sutomer about his payment state
    }
   
    receive() external payable {}
    
    fallback() external payable {}
}

//That contract is the intermediate contract and is used to send money at the order's waiting time, before sending the to the shop
//or back to the customer.
contract PaymentContract
{
    //that function sends money to the customer or to the shop.
    function payFunction(address payable _to, uint payment_amount) external payable
    {
        _to.transfer(payment_amount);
    }
    
receive() external payable {}
    
    fallback() external payable {}
}