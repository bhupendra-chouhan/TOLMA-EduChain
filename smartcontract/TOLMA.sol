// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScholarshipFund {
    struct ScholarshipScheme {
        string name;
        uint256 id;
        address owner;
        uint256 startDate;
        uint256 deadline;
        uint256 amount;
        bool isActive;
    }

    struct Application {
        address payable student;
        uint256 schemeId;
        uint256 applicationTime;
        bool isApproved;
        bool isPaid;
    }

    uint256 public nextSchemeId = 1;
    mapping(uint256 => ScholarshipScheme) public scholarshipSchemes;
    mapping(uint256 => Application[]) public applications;

    event ScholarshipSchemeListed(uint256 indexed id, string name, uint256 startDate, uint256 deadline, uint256 amount);
    event ScholarshipApplied(uint256 schemeId, address student);
    event ApplicationReviewed(uint256 schemeId, address student, bool isApproved);
    event ScholarshipAmountSent(uint256 indexed schemeId, address indexed  student, uint256 amount);

    function listScholarshipScheme(string memory _name, uint256 _startDate, uint256 _deadline, uint256 _amount) public payable {
        require(_startDate < _deadline, "Start date must be before deadline");
        // require(msg.value == _amount, "Amount should be equal to the scholarship amount");

        scholarshipSchemes[nextSchemeId] = ScholarshipScheme({
            name: _name,
            id: nextSchemeId,
            owner: msg.sender,
            startDate: _startDate,
            deadline: _deadline,
            amount: _amount,
            isActive: true
        });

        emit ScholarshipSchemeListed(nextSchemeId, _name, _startDate, _deadline, _amount);
        nextSchemeId++;
    }

    function applyForScholarship(uint256 _schemeId) public {
        ScholarshipScheme memory scheme = scholarshipSchemes[_schemeId];
        require(scheme.isActive, "Scholarship scheme is not active");
        require(block.timestamp >= scheme.startDate, "Scholarship scheme not started yet");
        require(block.timestamp <= scheme.deadline, "Scholarship application period is over");

        applications[_schemeId].push(Application({
            student: payable(msg.sender),
            schemeId: _schemeId,
            applicationTime: block.timestamp,
            isApproved: false,
            isPaid: false
        }));

        emit ScholarshipApplied(_schemeId, msg.sender);
    }

    function reviewApplication(uint256 _schemeId, address _student, bool _approve) public {
        ScholarshipScheme storage scheme = scholarshipSchemes[_schemeId];
        require(scheme.owner == msg.sender, "Only the owner can review applications");
        
        Application[] storage schemeApplications = applications[_schemeId];
        for (uint256 i = 0; i < schemeApplications.length; i++) {
            if (schemeApplications[i].student == _student) {
                schemeApplications[i].isApproved = _approve;
                emit ApplicationReviewed(_schemeId, _student, _approve);
                return;
            }
        }
        revert("Application not found");
    }

    function sendScholarshipAmount(uint256 _schemeId, address _student) public {
        ScholarshipScheme storage scheme = scholarshipSchemes[_schemeId];
        require(scheme.owner == msg.sender, "Only the owner can send the scholarship amount");

        Application[] storage schemeApplications = applications[_schemeId];
        for (uint256 i = 0; i < schemeApplications.length; i++) {
            if (schemeApplications[i].student == _student) {
                require(schemeApplications[i].isApproved, "Application is not approved");
                // require(!schemeApplications[i].isPaid, "Scholarship already paid to this student");

                // Transfer the amount from the contract to the student's address
                schemeApplications[i].student.transfer(scheme.amount);
                schemeApplications[i].isPaid = true;

                emit ScholarshipAmountSent(_schemeId, _student, scheme.amount);
                return;
            }
        }
        revert("Application not found or not approved");
    }

    function getApplications(uint256 _schemeId) public view returns (Application[] memory) {
        return applications[_schemeId];
    }

    function deactivateScholarshipScheme(uint256 _schemeId) public {
        ScholarshipScheme storage scheme = scholarshipSchemes[_schemeId];
        require(scheme.owner == msg.sender, "Only the owner can deactivate the scheme");
        scheme.isActive = false;
    }
}