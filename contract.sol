// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.9.0;

contract SocialContract {
    struct Post {
        uint postId;
        address author;
        string content;
        uint createdAt;
    }

    struct Message {
        uint messageId;
        string content;
        address from;
        address to;
        uint createdAt;
    }

    mapping(uint => Post) public posts;

    mapping(address => uint[]) public postsByAuthor;

    mapping(address => Message[]) public conversations;

    mapping(address => mapping(address => bool)) public operators;

    mapping(address => address[]) public following;

    uint nextPostId;

    uint nextMessageId;

    function _createPost(address _author, string memory _content) internal {
        require(
            _author == msg.sender || operators[_author][msg.sender],
            "You don't have access"
        );

        posts[nextPostId] = Post(nextPostId, _author, _content, block.timestamp);

        postsByAuthor[_author].push(nextPostId);

        nextPostId++;
    }

    function _sendMessage(
        address _from,
        address _to,
        string memory _content
    ) internal {
        require(
            _from == msg.sender || operators[_from][msg.sender],
            "You don't have access"
        );

        conversations[_from].push(
            Message(nextMessageId, _content, _from, _to, block.timestamp)
        )
        nextMessageId++;
    }

    function createPost(string memory _content) public {
        _createPost(msg.sender, _content);
    }

    function createPost(address _author, string memory _content) public {
        _createPost(_author, _content);
    }

    function sendMessage(string memory _content, address _to) public {
        _sendMessage(msg.sender, _to, _content);
    }

    function sendMessage(
        address _from,
        address _to,
        string memory _content
    ) public {
        _sendMessage(_from, _to, _content);
    }

    function follow(address _followed) public {
        following[msg.sender].push(_followed);
    }

    function allow(address _operator) public {
        operators[msg.sender][_operator] = true;
    }

    function disallow(address _operator) public {
        operators[msg.sender][_operator] = false;
    }

    function getLatestPosts(uint count) public view returns (Post[] memory) {
        require(count > 0 && count <= nextPostId, "Count is not proper");
        Post[] memory _posts = new Post[](count);
        uint j;
        for (uint i = nextPostId - count; i < nextPostId; i++) {
            Post storage _post = posts[i];
            _posts[j] = Post(
                _post.postId,
                _post.author,
                _post.content,
                _post.createdAt
            );
            j++;
        }
        return _posts;
    }

    function getLatestOfAuthor(
        address _author,
        uint count
    ) public view returns (Post[] memory) {
        Post[] memory _posts = new Post[](count);
        uint[] memory postIds = postsByAuthor[_author];
        require(count > 0 && count <= postIds.length, "Count is not defined");
        uint j;
        for (uint i = postIds.length - count; i < postIds.length; i++) {
            Post storage _post = posts[postIds[i]];
            _posts[j] = Post(
                _post.postId,
                _post.author,
                _post.content,
                _post.createdAt
            );
            j++;
        }
        return _posts;
    }
}
