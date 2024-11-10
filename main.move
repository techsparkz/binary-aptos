module MyModule::VotingApp {

    use aptos_framework::signer;
    use std::vector;
    use aptos_framework::account;

    /// Struct representing a proposal for voting.
    struct Proposal has store, key {
        creator: address,            // Address of the proposal creator
        description: vector<u8>,     // Description of the proposal
        votes_for: u64,              // Number of votes in favor
        votes_against: u64,          // Number of votes against
        has_ended: bool,             // Whether voting has ended
    }

    /// Function to create a new proposal.
    public fun create_proposal(creator: &signer, description: vector<u8>) {
        let creator_address = signer::address_of(creator);
        assert!(!exists<Proposal>(creator_address), 1);

        let proposal = Proposal {
            creator: creator_address,
            description,
            votes_for: 0,
            votes_against: 0,
            has_ended: false,
        };

        move_to(creator, proposal);
    }

    /// Function to cast a vote.
    public fun vote(owner_address: address, in_favor: bool) acquires Proposal {
        let proposal = borrow_global_mut<Proposal>(owner_address);
        assert!(!proposal.has_ended, 2);

        if (in_favor) {
            proposal.votes_for = proposal.votes_for + 1;
        } else {
            proposal.votes_against = proposal.votes_against + 1;
        }
    }

    /// Function to end voting on a proposal.
    public fun end_voting(owner: &signer) acquires Proposal {
        let proposal = borrow_global_mut<Proposal>(signer::address_of(owner));
        proposal.has_ended = true;
    }

    /// View function to get proposal details.
    public fun get_proposal_details(owner_address: address): (vector<u8>, u64, u64, bool) acquires Proposal {
        let proposal = borrow_global<Proposal>(owner_address);
        (proposal.description, proposal.votes_for, proposal.votes_against, proposal.has_ended)
    }
}
