// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Layer3Edu {
    address public owner;
    uint256 public totalUsers;
    uint256 public totalCourses;

    struct Course {
        uint256 id;
        string title;
        string description;
        address creator;
        uint256 price;
    }

    struct Enrollment {
        address student;
        uint256 courseId;
    }

    mapping(uint256 => Course) public courses;
    mapping(address => Enrollment[]) public enrollments;

    event CourseCreated(uint256 id, string title, address creator, uint256 price);
    event CoursePurchased(address student, uint256 courseId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
        totalUsers = 0;
        totalCourses = 0;
    }

    function createCourse(string memory _title, string memory _description, uint256 _price) public {
        require(bytes(_title).length > 0, "Course title cannot be empty.");
        require(_price > 0, "Price must be greater than zero.");
        totalCourses++;
        courses[totalCourses] = Course(totalCourses, _title, _description, msg.sender, _price);

        emit CourseCreated(totalCourses, _title, msg.sender, _price);
    }

    function purchaseCourse(uint256 _courseId) public payable {
        Course memory course = courses[_courseId];
        require(course.id != 0, "Course does not exist.");
        require(msg.value == course.price, "Incorrect payment amount.");

        enrollments[msg.sender].push(Enrollment(msg.sender, _courseId));
        payable(course.creator).transfer(msg.value);

        emit CoursePurchased(msg.sender, _courseId);
    }

    function getCourses() public view returns (Course[] memory) {
        Course[] memory allCourses = new Course[](totalCourses);
        for (uint256 i = 1; i <= totalCourses; i++) {
            allCourses[i - 1] = courses[i];
        }
        return allCourses;
    }

    function getEnrollments(address _student) public view returns (Enrollment[] memory) {
        return enrollments[_student];
    }
}
